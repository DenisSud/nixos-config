"""Command line interface and the GNOME keybinding wiring."""

from __future__ import annotations

import argparse
import ast
import json
import os
import shutil
import socket
import subprocess
import sys
import tempfile
import time
from pathlib import Path
from typing import Any

from .config import APP, Config
from .dataset import Dataset, NullDataset
from .logging_util import log_path, setup_logging

ENGINE_NAME = "parakeet"
MEDIA_KEYS_SCHEMA = "org.gnome.settings-daemon.plugins.media-keys"
KEYBINDING_PATH = (
    "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/parakeet-typing/"
)
KEYBINDING_NAME = "Parakeet dictation"


# ---------------------------------------------------------------------------
# Small helpers
# ---------------------------------------------------------------------------
def _notify(title: str, body: str) -> None:
    binary = shutil.which("notify-send")
    if not binary:
        return
    try:
        subprocess.Popen(
            [binary, "-a", APP, title, body],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            start_new_session=True,
        )
    except OSError:
        pass


def _fail(message: str) -> int:
    print(f"error: {message}", file=sys.stderr)
    _notify("Parakeet dictation", message)
    return 1


def _request(cfg: Config, cmd: str, timeout: float = 2.0) -> dict[str, Any] | None:
    if not cfg.socket_path.exists():
        return None
    try:
        with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as sock:
            sock.settimeout(timeout)
            sock.connect(str(cfg.socket_path))
            sock.sendall(json.dumps({"cmd": cmd}).encode("utf-8") + b"\n")
            data = b""
            while b"\n" not in data:
                chunk = sock.recv(65536)
                if not chunk:
                    break
                data += chunk
    except (OSError, TimeoutError):
        return None
    if not data:
        return None
    try:
        return json.loads(data.decode("utf-8"))
    except json.JSONDecodeError:
        return None


def _run_ibus(cfg: Config, *args: str, timeout: float = 5.0) -> subprocess.CompletedProcess:
    return subprocess.run(
        [cfg.ibus, *args],
        capture_output=True,
        text=True,
        timeout=timeout,
        check=False,
    )


def current_engine(cfg: Config) -> str | None:
    try:
        proc = _run_ibus(cfg, "engine")
    except (OSError, subprocess.TimeoutExpired):
        return None
    return proc.stdout.strip() or None


def _switch_engine(cfg: Config, name: str) -> bool:
    try:
        _run_ibus(cfg, "engine", name)
    except (OSError, subprocess.TimeoutExpired):
        return False
    # `ibus engine` exits non-zero when it cannot run setxkbmap, which is
    # common on Wayland/NixOS, even though the switch itself succeeded.  Trust
    # the active engine rather than the exit status.
    for _ in range(12):
        if current_engine(cfg) == name:
            return True
        time.sleep(0.05)
    return False


def _write_pending(cfg: Config, prev: str | None) -> None:
    tmp = cfg.pending_path.with_suffix(".tmp")
    tmp.write_text(
        json.dumps({"prev": prev, "ts": time.time()}), encoding="utf-8"
    )
    tmp.replace(cfg.pending_path)


def _clear_pending(cfg: Config) -> None:
    try:
        cfg.pending_path.unlink()
    except OSError:
        pass


def _wait_started(
    cfg: Config, prev: str | None, timeout: float = 6.0, *, quiet: bool = False
) -> int:
    deadline = time.monotonic() + timeout
    sent_start = False
    while time.monotonic() < deadline:
        st = _request(cfg, "status", timeout=0.5)
        if st:
            state = st.get("state")
            if state in ("loading", "listening"):
                return 0
            if state == "idle" and st.get("engine_active") and not sent_start:
                _request(cfg, "start", timeout=0.5)
                sent_start = True
        time.sleep(0.10)

    # The engine was selected but never started.  Put the previous input
    # source back so the user is not stuck on a dead engine.
    _clear_pending(cfg)
    if current_engine(cfg) == ENGINE_NAME:
        if prev:
            _switch_engine(cfg, prev)
        else:
            _switch_engine(cfg, "xkb:us::eng")
    message = (
        "engine did not start. Check `parakeet-typing doctor` and the log at "
        + str(log_path(cfg))
    )
    return 0 if quiet else _fail(message)


# ---------------------------------------------------------------------------
# Commands
# ---------------------------------------------------------------------------
def cmd_toggle(cfg: Config) -> int:
    st = _request(cfg, "status")
    state = st.get("state") if st else None

    if state in ("loading", "listening", "stopping"):
        _request(cfg, "stop")
        return 0
    if state == "correction":
        # The engine is still the active input source; start a new session
        # and finalise the correction tracking in the background.
        _request(cfg, "start")
        return 0
    if state == "idle" and st.get("engine_active"):
        _request(cfg, "start")
        time.sleep(0.15)
        st = _request(cfg, "status")
        if st and st.get("state") in ("loading", "listening"):
            return 0
        return _fail("engine is active but could not start a session")

    prev = current_engine(cfg)
    if prev == ENGINE_NAME:
        if st is None:
            return _fail(
                "the parakeet IBus engine is selected but its process is not "
                "answering; run `ibus restart` and try again"
            )
        _request(cfg, "start")
        return _wait_started(cfg, prev)

    _write_pending(cfg, prev)
    if not _switch_engine(cfg, ENGINE_NAME):
        _clear_pending(cfg)
        return _fail(
            "could not select the `parakeet` input source. Is the engine "
            "installed? Try `parakeet-typing doctor` and `ibus restart`."
        )
    return _wait_started(cfg, prev)


def cmd_start(cfg: Config) -> int:
    st = _request(cfg, "status")
    if st and st.get("state") in ("loading", "listening"):
        print("already listening")
        return 0
    if st and st.get("engine_active"):
        _request(cfg, "start")
        return 0
    return cmd_toggle(cfg)


def cmd_stop(cfg: Config) -> int:
    st = _request(cfg, "status")
    if not st:
        return _fail("engine is not running")
    if st.get("state") == "correction":
        _request(cfg, "finish")
        return 0
    if st.get("state") in ("loading", "listening", "stopping"):
        _request(cfg, "stop")
        return 0
    print("nothing to stop")
    return 0


def cmd_cancel(cfg: Config) -> int:
    st = _request(cfg, "status")
    if not st:
        return _fail("engine is not running")
    _request(cfg, "cancel")
    return 0


def cmd_status(cfg: Config) -> int:
    st = _request(cfg, "status")
    dataset = Dataset(cfg)
    payload = {
        "engine": st if st else {"state": "not running"},
        "dataset": dataset.stats(),
        "log": str(log_path(cfg)),
        "config_file": str(cfg.config_path),
    }
    print(json.dumps(payload, indent=2, ensure_ascii=False))
    return 0


def cmd_stats(cfg: Config) -> int:
    print(json.dumps(Dataset(cfg).stats(), indent=2))
    return 0


def _gsettings(*args: str) -> subprocess.CompletedProcess:
    binary = shutil.which("gsettings")
    if not binary:
        raise FileNotFoundError("gsettings not found in PATH")
    return subprocess.run(
        [binary, *args], capture_output=True, text=True, check=False, timeout=10
    )


def _gsettings_get_list(schema: str, key: str) -> list[str]:
    proc = _gsettings("get", schema, key)
    out = proc.stdout.strip()
    if out.startswith("@as "):
        out = out[4:].strip()
    try:
        value = ast.literal_eval(out)
    except (SyntaxError, ValueError):
        return []
    return [str(x) for x in value] if isinstance(value, (list, tuple)) else []


def _gsettings_get_str(schema: str, key: str) -> str:
    proc = _gsettings("get", schema, key)
    out = proc.stdout.strip()
    if len(out) >= 2 and out[0] == out[-1] == "'":
        return out[1:-1]
    if len(out) >= 2 and out[0] == out[-1] == '"':
        return out[1:-1]
    return out


def _gsettings_set(schema: str, key: str, value: str) -> bool:
    proc = _gsettings("set", schema, key, value)
    if proc.returncode != 0:
        print(f"warning: gsettings set {schema} {key} failed: {proc.stderr.strip()}")
        return False
    return True


def _binary_path() -> str:
    for candidate in (
        "/run/current-system/sw/bin/parakeet-typing",
        shutil.which("parakeet-typing"),
        os.path.abspath(sys.argv[0]),
    ):
        if candidate and Path(candidate).exists():
            return str(candidate)
    return "parakeet-typing"


def cmd_setup(
    cfg: Config,
    *,
    binding: str | None = None,
    quiet: bool = False,
    extension: str | None = None,
) -> int:
    binding = binding or cfg.hotkey
    command = f"{_binary_path()} toggle"
    reloc = f"{MEDIA_KEYS_SCHEMA}.custom-keybinding:{KEYBINDING_PATH}"

    try:
        current = _gsettings_get_list(MEDIA_KEYS_SCHEMA, "custom-keybindings")
    except (FileNotFoundError, subprocess.TimeoutExpired) as exc:
        return _fail(str(exc))

    changed = False
    if KEYBINDING_PATH not in current:
        current.append(KEYBINDING_PATH)
        if not _gsettings_set(
            MEDIA_KEYS_SCHEMA, "custom-keybindings", repr(current)
        ):
            return _fail("could not update the custom keybindings list")
        changed = True

    for key, value in (
        ("name", KEYBINDING_NAME),
        ("command", command),
        ("binding", binding),
    ):
        try:
            existing = _gsettings_get_str(reloc, key)
        except (FileNotFoundError, subprocess.TimeoutExpired) as exc:
            return _fail(str(exc))
        if existing != value:
            if not _gsettings_set(reloc, key, value):
                return _fail(f"could not set {key}")
            changed = True

    if extension:
        try:
            enabled = _gsettings_get_list("org.gnome.shell", "enabled-extensions")
        except (FileNotFoundError, subprocess.TimeoutExpired) as exc:
            return _fail(str(exc))
        if extension not in enabled:
            enabled.append(extension)
            if not _gsettings_set("org.gnome.shell", "enabled-extensions", repr(enabled)):
                return _fail("could not enable the indicator extension")
            changed = True

        # Best effort: ask the running shell to pick it up now as well.  At
        # login the extension is already discovered, so this normally succeeds
        # and saves a second logout.  If the shell is not up yet, the setting
        # above still applies on the next shell start.
        gnome_extensions = shutil.which("gnome-extensions")
        if gnome_extensions:
            try:
                subprocess.run(
                    [gnome_extensions, "enable", extension],
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                    timeout=10,
                    check=False,
                )
            except (OSError, subprocess.TimeoutExpired):
                pass

    if not quiet:
        print(
            ("updated" if changed else "unchanged")
            + f": {binding} -> {command}"
            + (f" (+ {extension})" if extension else "")
        )
    return 0


def cmd_doctor(cfg: Config, *, check_mic: bool = False) -> int:
    issues: list[str] = []

    def ok(label: str, detail: str = "") -> None:
        print(f"  ok   {label}" + (f"  ({detail})" if detail else ""))

    def warn(label: str, detail: str = "") -> None:
        print(f"  warn {label}" + (f"  ({detail})" if detail else ""))

    def bad(label: str, detail: str = "") -> None:
        print(f"  FAIL {label}" + (f"  ({detail})" if detail else ""))
        issues.append(label)

    print(f"{APP} doctor")
    print(f"  config : {cfg.config_path}")
    print(f"  data   : {cfg.data_dir}")
    print(f"  log    : {log_path(cfg)}")

    try:
        import gi

        gi.require_version("IBus", "1.0")
        from gi.repository import IBus  # noqa: F401
        ok("python3 + PyGObject + IBus typelib")
    except Exception as exc:  # noqa: BLE001
        bad("PyGObject / IBus typelib", str(exc))

    try:
        import sherpa_onnx  # noqa: F401
        ok("sherpa-onnx")
    except Exception as exc:  # noqa: BLE001
        bad("sherpa-onnx", str(exc))

    missing = [
        name
        for name in (
            "encoder.int8.onnx",
            "decoder.int8.onnx",
            "joiner.int8.onnx",
            "tokens.txt",
            "silero_vad.onnx",
        )
        if not (Path(cfg.model_dir) / name).is_file()
    ]
    if missing:
        bad("Parakeet model files", ", ".join(missing))
    else:
        size = sum(
            (Path(cfg.model_dir) / name).stat().st_size
            for name in (
                "encoder.int8.onnx",
                "decoder.int8.onnx",
                "joiner.int8.onnx",
                "tokens.txt",
                "silero_vad.onnx",
            )
        )
        ok("Parakeet model", f"{size / 1e6:.0f} MB in {cfg.model_dir}")

    for binary, label in (
        (cfg.pw_record, "pw-record"),
        (cfg.pw_play, "pw-play"),
        (cfg.ibus, "ibus"),
    ):
        if shutil.which(binary):
            ok(label, shutil.which(binary) or "")
        else:
            bad(label, "not found in PATH")

    engine_listed = False
    try:
        proc = _run_ibus(cfg, "list-engine")
        for line in proc.stdout.splitlines():
            stripped = line.strip().lower()
            if stripped.startswith(ENGINE_NAME + " - "):
                engine_listed = True
                break
    except (OSError, subprocess.TimeoutExpired):
        pass
    if engine_listed:
        ok("IBus engine registered")
    else:
        bad(
            "IBus engine registered",
            "not found in `ibus list-engine`; rebuild + relogin, or `ibus restart`",
        )

    st = _request(cfg, "status")
    if st:
        ok(
            "engine process",
            f"state={st.get('state')} model_loaded={st.get('model_loaded')}",
        )
    else:
        warn(
            "engine process",
            "not running (normal: ibus-daemon starts it on first activation)",
        )

    try:
        current = _gsettings_get_list(MEDIA_KEYS_SCHEMA, "custom-keybindings")
        reloc = f"{MEDIA_KEYS_SCHEMA}.custom-keybinding:{KEYBINDING_PATH}"
        if KEYBINDING_PATH in current:
            binding = _gsettings_get_str(reloc, "binding")
            command = _gsettings_get_str(reloc, "command")
            if binding == cfg.hotkey:
                ok("keybinding", f"{binding} -> {command}")
            else:
                bad("keybinding", f"configured {binding!r}, expected {cfg.hotkey!r}")
        else:
            bad("keybinding", "not installed; run `parakeet-typing setup`")
    except (FileNotFoundError, subprocess.TimeoutExpired) as exc:
        bad("keybinding", str(exc))

    if check_mic:
        try:
            from .audio import AudioCapture

            cap = AudioCapture(cfg)
            cap.start()
            frames = []
            for _ in range(int(1000 / cfg.frame_ms)):
                frame = cap.read()
                if frame is not None:
                    frames.append(frame)
            cap.close()
            import numpy as np

            if frames:
                level = float(np.sqrt(np.mean(np.concatenate(frames) ** 2)))
                if level < 1e-5:
                    warn(
                        "microphone",
                        "captured silence; the default source may be muted "
                        "(wpctl set-mute @DEFAULT_AUDIO_SOURCE@ 0)",
                    )
                else:
                    ok("microphone", f"RMS {level:.4f} over 1 s")
            else:
                bad("microphone", "no audio frames received")
        except Exception as exc:  # noqa: BLE001
            bad("microphone", str(exc))

    ext_uuid = "parakeet-indicator@denis"
    data_dirs = os.environ.get("XDG_DATA_DIRS", "/usr/share").split(":")
    ext_dir = next(
        (
            Path(base) / "gnome-shell" / "extensions" / ext_uuid
            for base in data_dirs
            if (Path(base) / "gnome-shell" / "extensions" / ext_uuid).is_dir()
        ),
        None,
    )
    if ext_dir:
        ok("indicator extension", str(ext_dir))
    else:
        bad("indicator extension", "not installed in XDG_DATA_DIRS")

    try:
        enabled_exts = _gsettings_get_list("org.gnome.shell", "enabled-extensions")
        if ext_uuid in enabled_exts:
            ok("indicator extension enabled")
        else:
            bad(
                "indicator extension enabled",
                f"run `parakeet-typing setup --extension {ext_uuid}`",
            )
        if _gsettings_get_str("org.gnome.shell", "disable-user-extensions") == "true":
            warn("user extensions are disabled", "org.gnome.shell disable-user-extensions")
    except (FileNotFoundError, subprocess.TimeoutExpired) as exc:
        bad("indicator extension enabled", str(exc))

    wpctl = shutil.which("wpctl")
    if wpctl:
        try:
            proc = subprocess.run(
                [wpctl, "get-volume", "@DEFAULT_AUDIO_SOURCE@"],
                capture_output=True,
                text=True,
                timeout=5,
                check=False,
            )
            if "MUTED" in proc.stdout:
                warn(
                    "default microphone is muted",
                    "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ 0",
                )
        except (OSError, subprocess.TimeoutExpired):
            pass

    stats = Dataset(cfg).stats()
    ok(
        "dataset",
        f"{stats['utterances']} utterances, {stats['corrected']} reviewed, "
        f"{stats['audio_bytes'] / 1e6:.1f} MB",
    )

    if issues:
        print(f"\n{len(issues)} issue(s) need attention")
        return 1
    print("\nall checks passed")
    return 0


def cmd_stream(cfg: Config, path: str, *, pace: bool = True) -> int:
    from .session import Session

    dataset = NullDataset()
    done = {"value": False}

    def on_partial(text: str) -> None:
        print(f"partial: {text}")

    def on_segment(segment: Any) -> None:
        print(f"FINAL  : {segment.text}")

    def on_done(reason: str) -> None:
        print(f"done   : {reason}")
        done["value"] = True

    def on_error(message: str) -> None:
        print(f"error  : {message}", file=sys.stderr)

    from .asr import AsrEngine

    asr = AsrEngine(cfg, setup_logging(cfg, stderr=True))
    session = Session(
        cfg,
        asr,
        dataset,
        session_id="stream",
        on_partial=on_partial,
        on_segment=on_segment,
        on_done=on_done,
        on_error=on_error,
        source_file=path,
    )
    session.start()
    try:
        while not done["value"]:
            time.sleep(0.1)
    except KeyboardInterrupt:
        session.stop(cancel=True)
        session.join(5)
    return 0


def cmd_review(cfg: Config, *, limit: int, include_reviewed: bool, audio: bool) -> int:
    dataset = Dataset(cfg)
    entries = [
        e
        for e in dataset.merged()
        if e.get("text")
        and (e.get("audio") or not audio)
        and (include_reviewed or "corrected_text" not in e)
    ]
    entries = entries[-limit:] if limit > 0 else entries
    if not entries:
        print("nothing to review")
        return 0

    editor = os.environ.get("VISUAL") or os.environ.get("EDITOR") or "nano"
    reviewed = 0
    for index, entry in enumerate(reversed(entries), 1):
        print("\n" + "─" * 70)
        print(
            f"[{index}/{len(entries)}] {entry.get('created_at', '?')}  "
            f"{entry.get('duration_s', 0):.2f}s  {entry['id']}"
        )
        if entry.get("corrected_text") is not None:
            print(f"already reviewed: {entry['corrected_text']}")
        print(f"hypothesis: {entry['text']}")

        path = dataset.audio_path(entry)
        if audio and path:
            try:
                subprocess.run(
                    [cfg.pw_play, str(path)],
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                    check=False,
                )
            except OSError as exc:
                print(f"(could not play audio: {exc})")

        try:
            choice = input("keep / edit / skip / quit [k/e/s/q]: ").strip().lower()
        except (EOFError, KeyboardInterrupt):
            print()
            break
        if choice in ("q", "quit"):
            break
        if choice in ("s", "skip", ""):
            continue
        if choice in ("k", "keep"):
            corrected = entry["text"]
        elif choice in ("e", "edit"):
            corrected = _edit_text(editor, entry["text"])
            if corrected is None:
                continue
        else:
            corrected = choice  # allow pasting the corrected text directly

        dataset.add_correction(
            entry["id"],
            committed_text=entry["text"],
            final_text=corrected,
            reliable=True,
            edited=corrected != entry["text"],
            events=[],
            reason="review",
            appended_chars=0,
        )
        reviewed += 1

    print(f"\nreviewed {reviewed} utterance(s); corrections in {dataset.corrections_path}")
    return 0


def _edit_text(editor: str, text: str) -> str | None:
    import shlex

    with tempfile.NamedTemporaryFile(
        mode="w", suffix=".txt", encoding="utf-8", delete=False
    ) as tmp:
        tmp.write(text + "\n")
        path = tmp.name
    try:
        proc = subprocess.run([*shlex.split(editor), path], check=False)
        if proc.returncode != 0:
            print(f"editor exited with {proc.returncode}")
            return None
        return Path(path).read_text(encoding="utf-8").strip()
    finally:
        try:
            Path(path).unlink()
        except OSError:
            pass


def cmd_export(
    cfg: Config,
    out_dir: str,
    *,
    corrected_only: bool,
    use_tracked: bool,
) -> int:
    dataset = Dataset(cfg)
    out = Path(out_dir).expanduser().resolve()
    out.mkdir(parents=True, exist_ok=True)
    meta_path = out / "metadata.jsonl"
    copied = 0
    skipped = 0
    total_bytes = 0

    with meta_path.open("w", encoding="utf-8") as meta:
        for entry in dataset.merged():
            audio_path = dataset.audio_path(entry)
            text = entry.get("corrected_text")
            if text is None and use_tracked:
                correction = entry.get("correction") or {}
                if correction.get("reliable") and correction.get("edited"):
                    text = correction.get("final_text")
            if text is None:
                text = entry.get("text")
            if corrected_only and entry.get("corrected_text") is None:
                skipped += 1
                continue
            if not audio_path or not text:
                skipped += 1
                continue

            rel = Path(entry["audio"])
            target = out / rel
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(audio_path, target)
            total_bytes += target.stat().st_size
            meta.write(
                json.dumps(
                    {
                        "file_name": str(rel),
                        "transcription": text,
                        "duration": entry.get("duration_s"),
                        "reviewed": "corrected_text" in entry,
                    },
                    ensure_ascii=False,
                )
                + "\n"
            )
            copied += 1

    info = {
        "dataset": "parakeet-typing dictation samples",
        "model": "nvidia/parakeet-tdt-0.6b-v3 (int8 ONNX via sherpa-onnx)",
        "sample_rate": 16000,
        "utterances": copied,
        "skipped": skipped,
        "audio_bytes": total_bytes,
        "format": "Hugging Face audiofolder (metadata.jsonl + audio/)",
    }
    (out / "dataset_info.json").write_text(
        json.dumps(info, indent=2), encoding="utf-8"
    )
    print(
        f"exported {copied} utterance(s), {total_bytes / 1e6:.1f} MB -> {out}\n"
        f"  metadata: {meta_path}\n  skipped : {skipped}"
    )
    return 0


def cmd_engine() -> int:
    from .engine import run_engine

    run_engine()
    return 0


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------
def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog=APP,
        description="Parakeet TDT v3 voice typing for GNOME (IBus engine).",
    )
    parser.add_argument("--version", action="version", version="parakeet-typing 0.1.0")
    sub = parser.add_subparsers(dest="command", required=True)

    sub.add_parser("toggle", help="start/stop dictation (bind this to a key)")
    sub.add_parser("start", help="start dictation")
    sub.add_parser("stop", help="finish and commit the current utterance")
    sub.add_parser("cancel", help="discard the current utterance")
    sub.add_parser("status", help="show engine and dataset status")
    sub.add_parser("stats", help="show dataset statistics")
    sub.add_parser("engine", help="run the IBus engine (internal)")

    setup = sub.add_parser("setup", help="install the GNOME custom keybinding")
    setup.add_argument("--binding", default=None, help="e.g. '<Super><Alt>v'")
    setup.add_argument("--quiet", action="store_true")

    setup.add_argument(
        "--extension",
        default=None,
        help="GNOME Shell extension UUID to enable (e.g. parakeet-indicator@denis)",
    )

    doctor = sub.add_parser("doctor", help="check the installation")
    doctor.add_argument("--mic", action="store_true", help="also test microphone capture")

    stream = sub.add_parser(
        "stream", help="run the streaming pipeline on a WAV file (debug)"
    )
    stream.add_argument("wav")
    stream.add_argument("--no-pace", action="store_true")

    review = sub.add_parser("review", help="listen to recent utterances and correct text")
    review.add_argument("--limit", type=int, default=20)
    review.add_argument("--all", action="store_true", help="include reviewed entries")
    review.add_argument("--no-audio", action="store_true")

    export = sub.add_parser("export", help="export a Hugging Face audiofolder dataset")
    export.add_argument("--out", required=True)
    export.add_argument("--corrected-only", action="store_true")
    export.add_argument(
        "--use-tracked",
        action="store_true",
        help="use reliable post-commit edit tracking as the label",
    )
    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)

    cfg = Config.load()
    setup_logging(cfg, stderr=args.command not in ("engine",))

    if args.command == "engine":
        return cmd_engine()
    if args.command == "toggle":
        return cmd_toggle(cfg)
    if args.command == "start":
        return cmd_start(cfg)
    if args.command == "stop":
        return cmd_stop(cfg)
    if args.command == "cancel":
        return cmd_cancel(cfg)
    if args.command == "status":
        return cmd_status(cfg)
    if args.command == "stats":
        return cmd_stats(cfg)
    if args.command == "setup":
        return cmd_setup(
            cfg,
            binding=args.binding,
            quiet=args.quiet,
            extension=args.extension,
        )
    if args.command == "doctor":
        return cmd_doctor(cfg, check_mic=args.mic)
    if args.command == "stream":
        return cmd_stream(cfg, args.wav, pace=not args.no_pace)
    if args.command == "review":
        return cmd_review(
            cfg,
            limit=args.limit,
            include_reviewed=args.all,
            audio=not args.no_audio,
        )
    if args.command == "export":
        return cmd_export(
            cfg,
            args.out,
            corrected_only=args.corrected_only,
            use_tracked=args.use_tracked,
        )
    parser.error(f"unknown command {args.command}")
    return 2


if __name__ == "__main__":
    sys.exit(main())
