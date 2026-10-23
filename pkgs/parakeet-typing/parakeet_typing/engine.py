"""IBus engine + control socket for parakeet-typing.

The engine process is started by ibus-daemon when the `parakeet` input
source is selected.  It owns the Parakeet recognizer (loaded once and kept
warm), one dictation session at a time, and a small JSON control socket used
by the `parakeet-typing` CLI.

Why IBus: on GNOME Wayland the only reliable way to insert arbitrary
Unicode text into any focused application is an input method.  uinput-based
typers (ydotool/dotool) cannot do a live preedit and are a much bigger
security/permissions hammer.  The preedit also gives us real streaming: the
hypothesis is shown underlined in the target field while the user speaks and
is committed atomically at the end.
"""

from __future__ import annotations

import json
import logging
import os
import shutil
import signal
import socketserver
import subprocess
import sys
import time
import uuid
from pathlib import Path
from typing import Any

import gi

gi.require_version("IBus", "1.0")
from gi.repository import Gio, GLib, IBus  # noqa: E402

from .asr import AsrEngine  # noqa: E402
from .config import APP, Config  # noqa: E402
from .dataset import Dataset  # noqa: E402
from .logging_util import log_path, setup_logging  # noqa: E402
from .session import Segment, Session  # noqa: E402
from .tracker import TextTracker  # noqa: E402

ENGINE_NAME = "parakeet"
COMPONENT_NAME = "org.freedesktop.IBus.ParakeetTyping"
PENDING_MAX_AGE = 15.0

# Small session-bus API consumed by the GNOME Shell indicator extension.
# Also usable from the shell (`gdbus call ... Confirm`).
DBUS_NAME = "org.denis.ParakeetTyping"
DBUS_PATH = "/org/denis/ParakeetTyping"
DBUS_IFACE = "org.denis.ParakeetTyping"
DBUS_XML = """
<node>
  <interface name="org.denis.ParakeetTyping">
    <method name="GetState">
      <arg type="s" direction="out"/>
    </method>
    <method name="GetLevel">
      <arg type="d" direction="out"/>
    </method>
    <method name="Confirm"/>
    <method name="Cancel"/>
    <method name="Toggle"/>
    <signal name="StateChanged">
      <arg type="s"/>
    </signal>
    <signal name="LevelChanged">
      <arg type="d"/>
    </signal>
  </interface>
</node>
"""

log = logging.getLogger(APP)


# ---------------------------------------------------------------------------
# Control socket
# ---------------------------------------------------------------------------
class _ControlHandler(socketserver.StreamRequestHandler):
    @property
    def manager(self) -> "Manager":
        return self.server.manager  # type: ignore[attr-defined]

    def handle(self) -> None:
        line = self.rfile.readline(8192)
        if not line:
            return
        try:
            request = json.loads(line.decode("utf-8"))
        except (UnicodeDecodeError, json.JSONDecodeError):
            self._reply({"ok": False, "error": "bad request"})
            return

        cmd = str(request.get("cmd", ""))
        if cmd == "status":
            self._reply(self.manager.status())
            return
        if cmd in {"start", "stop", "cancel", "finish"}:
            GLib.idle_add(self.manager.control, cmd)
            self._reply({"ok": True, "accepted": cmd, "state": self.manager.state})
            return
        if cmd == "ping":
            self._reply({"ok": True, "pong": True})
            return
        self._reply({"ok": False, "error": f"unknown command {cmd!r}"})

    def _reply(self, payload: dict[str, Any]) -> None:
        try:
            self.wfile.write(json.dumps(payload).encode("utf-8") + b"\n")
        except OSError:
            pass


class ControlServer(socketserver.ThreadingUnixStreamServer):
    daemon_threads = True

    def __init__(self, path: Path, manager: "Manager") -> None:
        self.manager = manager
        path.parent.mkdir(parents=True, exist_ok=True)
        if path.exists():
            try:
                path.unlink()
            except OSError as exc:
                log.warning("could not remove stale socket %s: %s", path, exc)
        super().__init__(str(path), _ControlHandler)
        os.chmod(path, 0o600)
        self.path = path

    def server_close(self) -> None:
        super().server_close()
        try:
            self.path.unlink()
        except OSError:
            pass


# ---------------------------------------------------------------------------
# Manager (one per engine process)
# ---------------------------------------------------------------------------
class Manager:
    def __init__(self, cfg: Config) -> None:
        self.cfg = cfg
        self.dataset = Dataset(cfg)
        self.asr = AsrEngine(cfg, log)
        self._state = "idle"  # idle | loading | listening | stopping | correction
        self.level = 0.0
        self._conn: Gio.DBusConnection | None = None
        self._dbus_owner: int | None = None
        self.active: "ParakeetEngine | None" = None
        self.session: Session | None = None
        self.generation = 0
        self.prev_engine: str | None = None
        self.tracker: TextTracker | None = None
        self.entry_id: str | None = None
        self.committed_text: str = ""
        self._correction_timer: int | None = None
        self._correction_grace_until = 0.0
        self._focus_suspect = False
        self._restoring = False
        self._restore_watchdog: int | None = None
        self.server: ControlServer | None = None

    # -- state ----------------------------------------------------------
    @property
    def state(self) -> str:
        return self._state

    @state.setter
    def state(self, value: str) -> None:
        if getattr(self, "_state", None) == value:
            return
        self._state = value
        self._emit_state()

    def _emit_state(self) -> None:
        conn = getattr(self, "_conn", None)
        if conn is None:
            return
        try:
            conn.emit_signal(
                None,
                DBUS_PATH,
                DBUS_IFACE,
                "StateChanged",
                GLib.Variant("(s)", (self._state,)),
            )
        except GLib.Error:
            pass

    def _emit_level(self) -> None:
        conn = getattr(self, "_conn", None)
        if conn is None:
            return
        try:
            conn.emit_signal(
                None,
                DBUS_PATH,
                DBUS_IFACE,
                "LevelChanged",
                GLib.Variant("(d)", (float(self.level),)),
            )
        except GLib.Error:
            pass

    # -- session bus (GNOME Shell indicator) -----------------------------
    def start_dbus(self) -> None:
        self._dbus_owner = Gio.bus_own_name(
            Gio.BusType.SESSION,
            DBUS_NAME,
            Gio.BusNameOwnerFlags.NONE,
            self._on_bus_acquired,
            None,
            None,
        )

    def _on_bus_acquired(
        self, connection: Gio.DBusConnection, name: str
    ) -> None:
        self._conn = connection
        info = Gio.DBusNodeInfo.new_for_xml(DBUS_XML)
        connection.register_object(
            DBUS_PATH,
            info.interfaces[0],
            self._on_method_call,
            None,
            None,
        )
        log.info("session bus service %s ready", DBUS_NAME)
        self._emit_state()
        self._emit_level()

    def _on_method_call(
        self,
        connection: Gio.DBusConnection,
        sender: str,
        object_path: str,
        interface_name: str,
        method_name: str,
        parameters: GLib.Variant,
        invocation: Gio.DBusMethodInvocation,
    ) -> None:
        if method_name == "GetState":
            invocation.return_value(GLib.Variant("(s)", (self.state,)))
            return
        if method_name == "GetLevel":
            invocation.return_value(GLib.Variant("(d)", (float(self.level),)))
            return
        if method_name == "Confirm":
            if self.state in ("loading", "listening", "stopping"):
                self.control("stop")
            elif self.state == "correction":
                self.control("finish")
            invocation.return_value(None)
            return
        if method_name == "Cancel":
            self.control("cancel")
            invocation.return_value(None)
            return
        if method_name == "Toggle":
            if self.state == "idle":
                self.control("start")
            elif self.state == "correction":
                self.control("finish")
            else:
                self.control("stop")
            invocation.return_value(None)
            return
        invocation.return_dbus_error(
            "org.denis.ParakeetTyping.UnknownMethod", method_name
        )

    # -- lifecycle ------------------------------------------------------
    def start_server(self) -> None:
        try:
            server = ControlServer(self.cfg.socket_path, self)
        except OSError as exc:
            log.error("cannot bind control socket %s: %s", self.cfg.socket_path, exc)
            return
        import threading

        threading.Thread(
            target=server.serve_forever, name="parakeet-control", daemon=True
        ).start()
        self.server = server
        log.info("control socket ready at %s", self.cfg.socket_path)

    def shutdown(self) -> None:
        if self.session is not None:
            self.session.stop(cancel=True)
        if self._dbus_owner is not None:
            Gio.bus_unown_name(self._dbus_owner)
            self._dbus_owner = None
        if self.server is not None:
            self.server.shutdown()
            self.server.server_close()

    # -- engine callbacks ----------------------------------------------
    def add_engine(self, engine: "ParakeetEngine") -> None:
        log.debug("engine instance %s created", engine.get_object_path())

    def on_enable(self, engine: "ParakeetEngine") -> None:
        log.info("engine enabled (state=%s)", self.state)
        self.active = engine
        engine.set_active(True)
        if self.state == "idle":
            pending = self._consume_pending()
            if pending is not None:
                self.prev_engine = pending.get("prev")
                self._start_session()
        elif self.state == "correction":
            # Re-selecting the engine during the correction window is fine;
            # keep tracking in the same client.
            pass

    def on_disable(self, engine: "ParakeetEngine") -> None:
        log.info("engine disabled (state=%s restoring=%s)", self.state, self._restoring)
        engine.set_active(False)
        if self._restoring:
            if self.active is engine:
                self.active = None
            if self.state != "correction":
                self.state = "idle"
            return
        if self.active is not engine:
            return
        self.active = None

        if self.state in ("loading", "listening", "stopping"):
            # The user picked another input source; do not yank it back.
            if self.session is not None:
                self.session.stop(cancel=True)
            self.state = "idle"
            self._clear_timer()
        elif self.state == "correction":
            self._finish_correction("input_source_changed", restore=False)
            self.state = "idle"

    def on_focus_in(self, engine: "ParakeetEngine") -> None:
        # While a session is running, keep talking to the engine instance that
        # actually received `enable`.  IBus can emit focus_in/focus_out while
        # the input source is switching; cancelling on those events would kill
        # a perfectly good session before the first word.
        if self.state in ("loading", "listening"):
            return
        if self.state == "correction" and self.active is not engine:
            if time.monotonic() < self._correction_grace_until:
                self._focus_suspect = True
                return
            self._finish_correction("focus_moved")
            return
        self.active = engine
        engine.set_active(True)

    def on_focus_out(self, engine: "ParakeetEngine") -> None:
        if self.active is not engine:
            return
        if self.state == "correction":
            if time.monotonic() < self._correction_grace_until:
                # IBus can emit a focus-out right after a commit while it
                # re-syncs the input context.  Do not throw the edit window
                # away for that; mark the sample as suspect instead.
                self._focus_suspect = True
                return
            self._finish_correction("focus_moved")

    def on_key(self, engine: "ParakeetEngine", keyval: int, keycode: int, state: int) -> bool:
        if self.state in ("loading", "listening"):
            if keyval == 0xFF1B:  # Escape
                log.info("escape pressed; cancelling")
                self._cancel_session()
                return True
            return False
        if self.state == "correction":
            if self.tracker is None:
                return False
            if keyval == 0xFF1B:  # Escape
                self._finish_correction("escape")
                return False
            unicode_char = IBus.keyval_to_unicode(keyval)
            if self._focus_suspect:
                self.tracker.reliable = False
            self.tracker.feed(keyval, state, unicode_char)
            self._reset_correction_timer()
            return False
        return False

    # -- session control ------------------------------------------------
    def _start_session(self) -> None:
        if self.state != "idle":
            return
        self.generation += 1
        gen = self.generation
        self.state = "loading"
        session_id = uuid.uuid4().hex[:12]
        log.info("starting session %s (prev engine %s)", session_id, self.prev_engine)
        self.session = Session(
            self.cfg,
            self.asr,
            self.dataset,
            session_id=session_id,
            on_partial=lambda text: self._cb_partial(gen, text),
            on_segment=lambda seg: self._cb_segment(gen, seg),
            on_done=lambda reason: self._cb_done(gen, reason),
            on_error=lambda message: self._cb_error(gen, message),
            on_level=lambda level: self._cb_level(gen, level),
            source_file=self.cfg.source_file,
        )
        self.session.start()

    def _cancel_session(self) -> None:
        if self.session is not None:
            self.session.stop(cancel=True)
        if self.state in ("loading", "listening"):
            self.state = "stopping"
        self._hide_preedit()
        self._restore_engine()

    def control(self, cmd: str) -> None:
        log.info("control command %s (state=%s)", cmd, self.state)
        if cmd == "start":
            if self.state == "correction":
                # Pressing the hotkey during the correction window means
                # "dictate again", not "stop tracking".
                self._finish_correction("hotkey", restore=False)
            if self.state == "idle" and self.active is not None:
                self._start_session()
        elif cmd == "stop":
            if self.state in ("loading", "listening"):
                if self.session is not None:
                    self.session.stop()
                self.state = "stopping"
            elif self.state == "idle":
                pass
        elif cmd == "cancel":
            self._cancel_session()
        elif cmd == "finish":
            if self.state == "correction":
                self._finish_correction("hotkey")

    # -- session callbacks (marshalled to the main loop) ----------------
    def _cb_partial(self, gen: int, text: str) -> None:
        GLib.idle_add(self._ui_partial, gen, text)

    def _cb_segment(self, gen: int, segment: Segment) -> None:
        GLib.idle_add(self._ui_segment, gen, segment)

    def _cb_done(self, gen: int, reason: str) -> None:
        GLib.idle_add(self._ui_done, gen, reason)

    def _cb_error(self, gen: int, message: str) -> None:
        GLib.idle_add(self._ui_error, gen, message)

    def _cb_level(self, gen: int, level: float) -> None:
        GLib.idle_add(self._ui_level, gen, level)

    def _ui_partial(self, gen: int, text: str) -> bool:
        if gen != self.generation or self.state not in ("loading", "listening"):
            return False
        self.state = "listening"
        self._show_preedit(text)
        return False

    def _ui_segment(self, gen: int, segment: Segment) -> bool:
        if gen != self.generation:
            return False
        if self.active is None or not self.active.is_active():
            log.warning("segment ready but engine is not active; text: %r", segment.text)
            return False
        if segment.text:
            log.info("commit: %r", segment.text)
            self.active.commit(segment.text)
        self._hide_preedit()
        if segment.is_last:
            self.state = "correction"
            self.entry_id = segment.entry_id
            self.committed_text = segment.text
            if segment.text:
                self._begin_correction(segment)
            else:
                self._restore_engine()
        return False

    def _ui_done(self, gen: int, reason: str) -> bool:
        if gen != self.generation:
            return False
        log.info("session done: %s (state=%s)", reason, self.state)
        self.session = None
        if self.state == "correction":
            return False
        self.state = "idle"
        self._hide_preedit()
        self._restore_engine()
        return False

    def _ui_level(self, gen: int, level: float) -> bool:
        if gen != self.generation:
            return False
        if self.state not in ("loading", "listening", "stopping"):
            return False
        self.level = float(level)
        self._emit_level()
        return False

    def _ui_error(self, gen: int, message: str) -> bool:
        if gen != self.generation:
            return False
        log.error("session error: %s", message)
        self._notify("Parakeet dictation error", message)
        return False

    # -- correction window ----------------------------------------------
    def _begin_correction(self, segment: Segment) -> None:
        if self.cfg.correction_window <= 0:
            self._restore_engine()
            self.state = "idle"
            return
        self.tracker = TextTracker(segment.text)
        self.state = "correction"
        self._focus_suspect = False
        self._correction_grace_until = time.monotonic() + 0.5
        self._reset_correction_timer()

    def _reset_correction_timer(self) -> None:
        self._clear_timer()
        self._correction_timer = GLib.timeout_add(
            max(1, int(self.cfg.correction_window * 1000)),
            self._on_correction_timeout,
        )

    def _on_correction_timeout(self) -> bool:
        self._correction_timer = None
        self._finish_correction("timeout")
        return False

    def _finish_correction(self, reason: str, *, restore: bool = True) -> None:
        self._clear_timer()
        tracker = self.tracker
        self.tracker = None
        if tracker is not None and self.entry_id is not None:
            final_text = tracker.final_text()
            reliable = (
                tracker.reliable
                and not self._focus_suspect
                and tracker.appended_chars
                <= max(30, int(len(tracker.initial) * 0.25))
            )
            self.dataset.add_correction(
                self.entry_id,
                committed_text=self.committed_text,
                final_text=final_text,
                reliable=reliable,
                edited=tracker.edited(),
                events=tracker.events,
                reason=reason,
                appended_chars=tracker.appended_chars,
            )
        self.entry_id = None
        self.committed_text = ""
        self._focus_suspect = False
        self.state = "idle"
        if restore:
            self._restore_engine()

    def _clear_timer(self) -> None:
        if self._correction_timer is not None:
            try:
                GLib.source_remove(self._correction_timer)
            except Exception:  # noqa: BLE001
                pass
            self._correction_timer = None

    # -- engine helpers --------------------------------------------------
    def _restore_engine(self) -> None:
        prev = self.prev_engine
        self.prev_engine = None
        if not prev or prev == ENGINE_NAME:
            return
        ibus = shutil.which(self.cfg.ibus) or self.cfg.ibus
        log.info("restoring input source %s", prev)
        self._restoring = True
        try:
            subprocess.Popen(
                [ibus, "engine", prev],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                start_new_session=True,
            )
        except OSError as exc:
            log.error("failed to restore input source: %s", exc)
            self._notify("Could not restore input source", str(exc))
        if self._restore_watchdog is not None:
            try:
                GLib.source_remove(self._restore_watchdog)
            except Exception:  # noqa: BLE001
                pass
        self._restore_watchdog = GLib.timeout_add(2000, self._clear_restoring)

    def _clear_restoring(self) -> bool:
        self._restoring = False
        self._restore_watchdog = None
        return False

    def _show_preedit(self, text: str) -> None:
        if self.active is None or not text:
            return
        engine = self.active
        ibus_text = IBus.Text.new_from_string(text)
        ibus_text.append_attribute(
            IBus.AttrType.UNDERLINE, IBus.AttrUnderline.SINGLE, 0, len(text)
        )
        engine.update_preedit_text_with_mode(
            ibus_text, len(text), True, IBus.PreeditFocusMode.CLEAR
        )

    def _hide_preedit(self) -> None:
        if self.active is not None:
            self.active.hide_preedit_text()

    # -- pending start ---------------------------------------------------
    def _consume_pending(self) -> dict[str, Any] | None:
        path = self.cfg.pending_path
        if not path.exists():
            return None
        try:
            data = json.loads(path.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError) as exc:
            log.warning("ignoring bad pending file: %s", exc)
            try:
                path.unlink()
            except OSError:
                pass
            return None
        try:
            path.unlink()
        except OSError:
            pass
        age = time.time() - float(data.get("ts", 0))
        if age > PENDING_MAX_AGE:
            log.warning("pending start is %.1fs old; ignoring", age)
            return None
        log.info("consumed pending start (previous engine %s)", data.get("prev"))
        return data

    # -- misc ------------------------------------------------------------
    def status(self) -> dict[str, Any]:
        return {
            "ok": True,
            "state": self.state,
            "engine_active": bool(self.active is not None and self.active.is_active()),
            "prev_engine": self.prev_engine,
            "model_loaded": self.asr.loaded,
            "socket": str(self.cfg.socket_path),
            "data_dir": str(self.cfg.data_dir),
            "config": self.cfg.status(),
        }

    def _notify(self, title: str, body: str) -> None:
        binary = shutil.which("notify-send")
        if not binary:
            return
        try:
            subprocess.Popen(
                [binary, "-a", "Parakeet dictation", title, body],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                start_new_session=True,
            )
        except OSError:
            pass


# ---------------------------------------------------------------------------
# IBus engine
# ---------------------------------------------------------------------------
class ParakeetEngine(IBus.Engine):
    __gtype_name__ = "ParakeetTypingEngine"

    def __init__(self, **kwargs: Any) -> None:
        super().__init__(**kwargs)
        self._active = False

    def is_active(self) -> bool:
        return self._active

    def set_active(self, value: bool) -> None:
        self._active = value

    def do_enable(self) -> None:
        MANAGER.on_enable(self)

    def do_disable(self) -> None:
        MANAGER.on_disable(self)

    def do_focus_in(self) -> None:
        MANAGER.on_focus_in(self)

    def do_focus_out(self) -> None:
        MANAGER.on_focus_out(self)

    def do_reset(self) -> None:
        self.hide_preedit_text()

    def do_process_key_event(self, keyval: int, keycode: int, state: int) -> bool:
        return MANAGER.on_key(self, keyval, keycode, state)

    # -- text helpers ----------------------------------------------------
    def commit(self, text: str) -> None:
        self.commit_text(IBus.Text.new_from_string(text))


class EngineFactory(IBus.Factory):
    __gtype_name__ = "ParakeetTypingEngineFactory"

    _counter = 0

    def __init__(self, bus: IBus.Bus) -> None:
        self._bus = bus
        super().__init__(
            object_path=IBus.PATH_FACTORY,
            connection=bus.get_connection(),
        )

    def do_create_engine(self, engine_name: str) -> ParakeetEngine:
        EngineFactory._counter += 1
        engine = ParakeetEngine(
            engine_name=engine_name,
            object_path=f"/org/freedesktop/IBus/Engine/Parakeet{EngineFactory._counter}",
            connection=self._bus.get_connection(),
        )
        MANAGER.add_engine(engine)
        return engine


MANAGER: Manager


def run_engine() -> None:
    global MANAGER
    cfg = Config.load()
    setup_logging(cfg)
    MANAGER = Manager(cfg)
    MANAGER.start_server()
    MANAGER.start_dbus()

    bus = IBus.Bus()
    if not bus.is_connected():
        log.error("cannot connect to the IBus bus")
        sys.exit(1)

    factory = EngineFactory(bus)
    log.info(
        "engine process ready (component %s, socket %s, log %s)",
        COMPONENT_NAME,
        cfg.socket_path,
        log_path(cfg),
    )
    bus.request_name(COMPONENT_NAME, 0)

    loop = GLib.MainLoop()

    def quit_handler(*_args: Any) -> bool:
        log.info("shutting down engine")
        MANAGER.shutdown()
        loop.quit()
        return False

    for sig in (signal.SIGTERM, signal.SIGINT):
        GLib.unix_signal_add(GLib.PRIORITY_HIGH, sig, quit_handler)

    try:
        loop.run()
    finally:
        if MANAGER.server is not None:
            MANAGER.server.server_close()
