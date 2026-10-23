"""One dictation session: capture -> VAD -> partial/final Parakeet decodes.

Runs on its own thread.  The IBus/GLib world only ever sees the callbacks;
the manager is responsible for marshalling those onto the GLib main loop.

Streaming model
---------------
Parakeet TDT v3 is an *offline* transducer: there is no purpose-built
streaming checkpoint for it (the streaming Parakeet models are English-only).
We therefore re-decode the current utterance on a fixed cadence (default
350 ms) and replace the preedit with the growing hypothesis.  On this machine
a 10 s utterance decodes in ~220 ms (39x realtime), so the cadence is
achievable with plenty of headroom.  A pause (VAD endpoint) triggers one
final decode and commits the text.
"""

from __future__ import annotations

import logging
from collections import deque
import threading
import time
from dataclasses import dataclass
from typing import Callable

import numpy as np

from .asr import AsrEngine
from .audio import AudioCapture, CaptureError, EndOfStream
from .config import Config
from .dataset import Dataset

log = logging.getLogger("parakeet-typing.session")

VAD_WINDOW = 512  # silero-vad window size used by sherpa-onnx


@dataclass
class Segment:
    text: str
    audio: np.ndarray
    entry_id: str
    segment_index: int
    is_last: bool
    info: dict


class Session:
    def __init__(
        self,
        cfg: Config,
        asr: AsrEngine,
        dataset: Dataset,
        *,
        session_id: str,
        on_partial: Callable[[str], None],
        on_segment: Callable[[Segment], None],
        on_done: Callable[[str], None],
        on_error: Callable[[str], None],
        on_level: Callable[[float], None] | None = None,
        source_file: str | None = None,
    ) -> None:
        self.cfg = cfg
        self.asr = asr
        self.dataset = dataset
        self.session_id = session_id
        self.on_partial = on_partial
        self.on_segment = on_segment
        self.on_done = on_done
        self.on_error = on_error
        self.on_level = on_level
        self.source_file = source_file

        self._stop = threading.Event()
        self._cancel = threading.Event()
        self._thread: threading.Thread | None = None
        self._done = False

    # -- lifecycle ------------------------------------------------------
    def start(self) -> None:
        self._thread = threading.Thread(
            target=self._run, name="parakeet-session", daemon=True
        )
        self._thread.start()

    def stop(self, *, cancel: bool = False) -> None:
        if cancel:
            self._cancel.set()
        self._stop.set()

    def join(self, timeout: float | None = None) -> None:
        if self._thread:
            self._thread.join(timeout)

    # -- worker ---------------------------------------------------------
    def _run(self) -> None:
        reason = "eof"
        capture: AudioCapture | None = None
        try:
            t_start = time.monotonic()
            load_ms = 0.0

            # Start capturing first and load the recognizer concurrently.
            # On the first activation after a fresh engine start the model
            # takes ~1 s to load; buffering the microphone during that time
            # means the first words are not lost.
            capture = AudioCapture(self.cfg, source_file=self.source_file)
            capture.start()

            buffered: deque[np.ndarray] = deque()
            load_error: list[BaseException] = []
            if not self.asr.loaded:
                loaded = threading.Event()

                def _load() -> None:
                    try:
                        self.asr.load()
                    except BaseException as exc:  # noqa: BLE001
                        load_error.append(exc)
                    finally:
                        loaded.set()

                t_load = time.monotonic()
                threading.Thread(target=_load, name="parakeet-load", daemon=True).start()
                while not loaded.is_set() and not self._stop.is_set():
                    frame = capture.read()
                    if frame is not None:
                        buffered.append(frame)
                load_ms = (time.monotonic() - t_load) * 1000.0
                if load_error:
                    raise load_error[0]

            vad = self.asr.make_vad()

            def next_frame() -> np.ndarray | None:
                if buffered:
                    return buffered.popleft()
                return capture.read()

            frame_samples = self.cfg.frame_samples
            pre_roll_samples = int(self.cfg.pre_roll * self.cfg.sample_rate)
            pre: list[np.ndarray] = []
            pre_len = 0
            utterance: list[np.ndarray] = []
            utter_len = 0
            vad_buf = np.zeros(0, dtype=np.float32)

            in_speech = False
            frame_index = 0
            next_partial = 0.0
            partial_text = ""
            partials: list[str] = []
            first_partial_ms: float | None = None
            max_partial_ms = 0.0
            speech_start = 0.0
            segment_index = 0

            while not self._stop.is_set():
                try:
                    frame = next_frame()
                except EndOfStream:
                    reason = "eof"
                    break
                if frame is None:
                    if not in_speech and (
                        time.monotonic() - t_start > self.cfg.idle_timeout
                    ):
                        reason = "idle_timeout"
                        break
                    continue

                frame_index += 1
                if self.on_level is not None and frame_index % 4 == 0:
                    rms = float(np.sqrt(np.mean(frame * frame)))
                    # Map RMS to 0..1 for the waveform.  Speech sits around
                    # 0.02-0.10 RMS with a normal mic; 0.12 is the reference
                    # for a full-height bar and the power curve keeps quiet
                    # voices visible.
                    level = min(1.0, (rms / 0.12) ** 0.7)
                    self.on_level(level)

                # Pre-roll ring (kept in frames; trimmed by sample count).
                pre.append(frame)
                pre_len += len(frame)
                while len(pre) > 1 and pre_len - len(pre[0]) >= pre_roll_samples:
                    pre_len -= len(pre.pop(0))

                # Feed silero VAD in its native 512-sample window.
                vad_buf = np.concatenate((vad_buf, frame))
                while len(vad_buf) >= VAD_WINDOW:
                    vad.accept_waveform(vad_buf[:VAD_WINDOW])
                    vad_buf = vad_buf[VAD_WINDOW:]

                if not in_speech:
                    if vad.is_speech_detected():
                        in_speech = True
                        # pre already contains the speech onset (detection
                        # lags the actual onset by ~100-300 ms).
                        utterance = list(pre)
                        utter_len = sum(len(f) for f in utterance)
                        speech_start = time.monotonic()
                        next_partial = speech_start + self.cfg.partial_interval
                    continue

                utterance.append(frame)
                utter_len += len(frame)
                now = time.monotonic()
                duration = utter_len / self.cfg.sample_rate

                # Split very long utterances so the re-decode cost stays
                # bounded and the user sees text appear while speaking.
                if duration >= self.cfg.max_utterance:
                    self._finalize(
                        utterance,
                        partials,
                        first_partial_ms,
                        max_partial_ms,
                        load_ms,
                        t_start,
                        speech_start,
                        segment_index,
                        last=False,
                        reason="max_length",
                    )
                    segment_index += 1
                    utterance = []
                    utter_len = 0
                    partials = []
                    partial_text = ""
                    first_partial_ms = None
                    max_partial_ms = 0.0
                    next_partial = now + self.cfg.partial_interval
                    if not vad.is_speech_detected():
                        reason = "silence"
                        break
                    continue

                if now >= next_partial and duration >= self.cfg.partial_min_audio:
                    audio = np.concatenate(utterance)
                    text, decode_ms = self.asr.transcribe(audio)
                    max_partial_ms = max(max_partial_ms, decode_ms)
                    if text and text != partial_text:
                        partial_text = text
                        partials.append(text)
                        if len(partials) > 50:
                            del partials[0]
                        if first_partial_ms is None:
                            first_partial_ms = (now - speech_start) * 1000.0
                        self.on_partial(text)
                    # Keep the worker comfortably below 50% duty cycle.
                    next_partial = now + max(
                        self.cfg.partial_interval, decode_ms / 1000.0 * 2.0
                    )

                if not vad.is_speech_detected():
                    # Endpoint: emit the final decode and stop (one-shot mode).
                    reason = "silence"
                    self._finalize(
                        utterance,
                        partials,
                        first_partial_ms,
                        max_partial_ms,
                        load_ms,
                        t_start,
                        speech_start,
                        segment_index,
                        last=True,
                        reason=reason,
                    )
                    utterance = []
                    utter_len = 0
                    segment_index += 1
                    break

                while not vad.empty():
                    vad.pop()  # release completed VAD segments

            if self.on_level is not None:
                self.on_level(0.0)

            if in_speech and utterance and not self._cancel.is_set():
                final_reason = "manual" if self._stop.is_set() else reason
                self._finalize(
                    utterance,
                    partials,
                    first_partial_ms,
                    max_partial_ms,
                    load_ms,
                    t_start,
                    speech_start,
                    segment_index,
                    last=True,
                    reason=final_reason,
                )
                reason = final_reason
            elif self._cancel.is_set():
                reason = "cancelled"

        except Exception as exc:  # noqa: BLE001 - report to the UI, never crash
            log.exception("session failed")
            self.on_error(str(exc))
            reason = "error"
        finally:
            if capture is not None:
                capture.close()
            self._emit_done(reason)

    def _finalize(
        self,
        utterance: list[np.ndarray],
        partials: list[str],
        first_partial_ms: float | None,
        max_partial_ms: float,
        load_ms: float,
        t_start: float,
        speech_start: float,
        segment_index: int,
        *,
        last: bool,
        reason: str,
    ) -> None:
        if not utterance:
            return
        audio = np.concatenate(utterance)
        duration = len(audio) / self.cfg.sample_rate
        if duration < self.cfg.min_speech:
            return
        text, final_ms = self.asr.transcribe(audio)
        latency = {
            "load_ms": round(load_ms, 1),
            "onset_ms": round((speech_start - t_start) * 1000.0, 1),
            "first_partial_ms": round(first_partial_ms, 1)
            if first_partial_ms is not None
            else None,
            "final_decode_ms": round(final_ms, 1),
            "max_partial_decode_ms": round(max_partial_ms, 1),
            "partials": len(partials),
            "session_ms": round((time.monotonic() - t_start) * 1000.0, 1),
        }
        info = {
            "latency_ms": latency,
            "reason": reason,
            "session_id": self.session_id,
        }
        entry_id = self.dataset.add_utterance(
            audio,
            text,
            partials=partials,
            info=info,
            segment_index=segment_index,
            is_last=last,
            source="file" if self.source_file else "mic",
        )
        self.on_segment(
            Segment(
                text=text,
                audio=audio,
                entry_id=entry_id,
                segment_index=segment_index,
                is_last=last,
                info=info,
            )
        )

    def _emit_done(self, reason: str) -> None:
        if self._done:
            return
        self._done = True
        try:
            self.on_done(reason)
        except Exception:  # noqa: BLE001
            log.exception("on_done callback failed")
