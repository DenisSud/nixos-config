"""One dictation session: capture -> VAD/endpointing -> partial/final decodes.

Runs on its own thread.  The IBus/GLib world only ever sees the callbacks;
the manager is responsible for marshalling those onto the GLib main loop.

Streaming model
---------------
Parakeet TDT v3 is an *offline* transducer: there is no purpose-built
streaming checkpoint for it (the streaming Parakeet models are English-only).
We therefore re-decode the current utterance on a fixed cadence (default
350 ms) and replace the preedit with the growing hypothesis.  On this machine
a 10 s utterance decodes in ~220 ms (39x realtime), so the cadence is
achievable with plenty of headroom.  An endpoint (see ``endpoint.py``)
triggers one final decode and commits the text.

The final decode gets *trimmed* audio: waiting out a 0.6-1.2 s hangover and
then feeding that dead air to the transducer regularly made it emit nothing
at all, which looked like "the text disappeared".  If a decode still comes
back empty or degenerate, the last non-empty partial is committed instead, so
a session never silently drops what the user saw on screen.
"""

from __future__ import annotations

import logging
import threading
import time
from collections import deque
from dataclasses import dataclass, field
from typing import Callable

import numpy as np

from .asr import AsrEngine
from .audio import AudioCapture, EndOfStream
from .config import Config
from .dataset import Dataset
from .endpoint import Endpointer, Event, looks_degenerate

log = logging.getLogger("parakeet-typing.session")


@dataclass
class Segment:
    text: str
    audio: np.ndarray
    entry_id: str
    segment_index: int
    is_last: bool
    info: dict


@dataclass
class _Current:
    """The utterance being built, plus the stats that go into the dataset."""

    frames: list[np.ndarray] = field(default_factory=list)
    samples: int = 0
    partials: list[str] = field(default_factory=list)
    partial_text: str = ""
    first_partial_ms: float | None = None
    max_partial_ms: float = 0.0
    speech_start: float = 0.0
    index: int = 0

    def reset(self, *, now: float, index: int) -> None:
        self.frames = []
        self.samples = 0
        self.partials = []
        self.partial_text = ""
        self.first_partial_ms = None
        self.max_partial_ms = 0.0
        self.speech_start = now
        self.index = index

    def append(self, frame: np.ndarray) -> None:
        self.frames.append(frame)
        self.samples += len(frame)


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
        endpointer: Endpointer | None = None
        current = _Current()
        t_start = time.monotonic()
        load_ms = 0.0
        rate = self.cfg.sample_rate
        try:
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
                    try:
                        frame = capture.read()
                    except EndOfStream:
                        break  # short file consumed before the model was ready
                    if frame is not None:
                        buffered.append(frame)
                # The buffer holds real-time audio; do not start decoding it
                # before the recognizer (and the audio clock) are ready.
                if not loaded.is_set() and not loaded.wait(30.0):
                    raise TimeoutError("recognizer load timed out")
                load_ms = (time.monotonic() - t_load) * 1000.0
                if load_error:
                    raise load_error[0]

            endpointer = Endpointer(self.cfg, self.asr.make_vad())

            def next_frame() -> np.ndarray | None:
                if buffered:
                    return buffered.popleft()
                return capture.read()

            pre: list[np.ndarray] = []
            pre_len = 0
            pre_roll = int(self.cfg.pre_roll * rate)
            frame_index = 0
            next_partial = 0.0

            while not self._stop.is_set():
                try:
                    frame = next_frame()
                except EndOfStream:
                    reason = "eof"
                    break
                if frame is None:
                    if (
                        not endpointer.in_speech
                        and time.monotonic() - t_start > self.cfg.idle_timeout
                    ):
                        reason = "idle_timeout"
                        break
                    continue

                now = time.monotonic()
                frame_index += 1
                if self.on_level is not None and frame_index % 4 == 0:
                    rms = float(np.sqrt(np.mean(frame * frame)))
                    # Map RMS to 0..1 for the waveform.  Speech sits around
                    # 0.02-0.10 RMS with a normal mic; 0.12 is the reference
                    # for a full-height bar and the power curve keeps quiet
                    # voices visible.
                    self.on_level(min(1.0, (rms / 0.12) ** 0.7))

                # Pre-roll ring: trimmed by sample count, not frame count.
                pre.append(frame)
                pre_len += len(frame)
                while len(pre) > 1 and pre_len - len(pre[0]) >= pre_roll:
                    pre_len -= len(pre.pop(0))

                event = endpointer.push(frame, now)

                if event is Event.IDLE:
                    if now - t_start > self.cfg.idle_timeout:
                        reason = "idle_timeout"
                        break
                    continue

                if event is Event.ONSET:
                    current.reset(now=now, index=current.index)
                    onset = endpointer.first_loud(pre)
                    current.frames = list(pre[onset:])
                    current.samples = sum(len(f) for f in current.frames)
                    next_partial = now + self.cfg.partial_interval
                    log.debug(
                        "speech onset (pre-roll %.2fs kept, floor %.1f dB)",
                        current.samples / rate,
                        endpointer.floor_db,
                    )
                    continue

                # Event.SPEECH / Event.END: this frame belongs to the utterance.
                current.append(frame)
                duration = current.samples / rate

                if event is Event.END:
                    reason = "silence"
                    self._finalize(
                        current,
                        endpointer,
                        t_start=t_start,
                        load_ms=load_ms,
                        last=True,
                        reason="silence",
                    )
                    current.reset(now=now, index=current.index + 1)
                    break

                # Split very long utterances so the re-decode cost stays
                # bounded and the user sees text appear while speaking.
                if duration >= self.cfg.max_utterance:
                    self._finalize(
                        current,
                        endpointer,
                        t_start=t_start,
                        load_ms=load_ms,
                        last=False,
                        reason="max_length",
                    )
                    current.reset(now=now, index=current.index + 1)
                    next_partial = now + self.cfg.partial_interval
                    continue

                if now >= next_partial and duration >= self.cfg.partial_min_audio:
                    text, decode_ms = self.asr.transcribe(np.concatenate(current.frames))
                    current.max_partial_ms = max(current.max_partial_ms, decode_ms)
                    if text and text != current.partial_text:
                        current.partial_text = text
                        current.partials.append(text)
                        if len(current.partials) > 50:
                            del current.partials[0]
                        if current.first_partial_ms is None:
                            current.first_partial_ms = (now - current.speech_start) * 1000.0
                        endpointer.mark_partial(text, now)
                        self.on_partial(text)
                    # Keep the worker comfortably below 50% duty cycle.
                    next_partial = now + max(
                        self.cfg.partial_interval, decode_ms / 1000.0 * 2.0
                    )

            if self.on_level is not None:
                self.on_level(0.0)

            if (
                endpointer is not None
                and endpointer.in_speech
                and current.frames
                and not self._cancel.is_set()
            ):
                final_reason = "manual" if self._stop.is_set() else reason
                self._finalize(
                    current,
                    endpointer,
                    t_start=t_start,
                    load_ms=load_ms,
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

    # -- decoding --------------------------------------------------------
    def _decode(
        self, audio: np.ndarray, fallback: str
    ) -> tuple[str, str, list[dict], float]:
        """Final decode with a retry and a partial fallback.

        Returns (text, source, attempts, decode_ms) where source is one of
        ``final``, ``final_retry`` or ``partial``.
        """
        rate = self.cfg.sample_rate
        attempts: list[dict] = []
        min_samples = int(max(self.cfg.min_speech, 1.0) * rate)
        text, ms, source = "", 0.0, "final"

        # The transducer sometimes emits nothing (or degenerates into a
        # repeated unit) when the tail still holds non-speech audio.  Shorter
        # prefixes recover the text; each retry costs ~200-400 ms and only
        # runs when the full decode failed.
        for index, fraction in enumerate((1.0, 0.85, 0.7)):
            sample_count = int(len(audio) * fraction)
            if index and sample_count < min_samples:
                break
            candidate_text, candidate_ms = self.asr.transcribe(audio[:sample_count])
            attempts.append(
                {
                    "audio_s": round(sample_count / rate, 3),
                    "text": candidate_text,
                    "ms": round(candidate_ms, 1),
                }
            )
            text, ms = candidate_text, candidate_ms
            source = "final" if index == 0 else "final_retry"
            if candidate_text and not looks_degenerate(candidate_text):
                break

        if (not text or looks_degenerate(text)) and fallback:
            if not looks_degenerate(fallback):
                log.warning(
                    "final decode %r unusable; committing the last partial %r",
                    text,
                    fallback,
                )
                text, source = fallback, "partial"

        return text, source, attempts, ms

    def _finalize(
        self,
        current: _Current,
        endpointer: Endpointer,
        *,
        t_start: float,
        load_ms: float,
        last: bool,
        reason: str,
    ) -> None:
        if not current.frames:
            return
        rate = self.cfg.sample_rate
        raw = np.concatenate(current.frames)
        raw_duration = len(raw) / rate
        if raw_duration < self.cfg.min_speech:
            return

        audio = endpointer.trim(raw)
        if len(audio) / rate < self.cfg.min_speech:
            audio = raw

        text, source, attempts, final_ms = self._decode(audio, current.partial_text)
        latency = {
            "load_ms": round(load_ms, 1),
            "onset_ms": round((current.speech_start - t_start) * 1000.0, 1),
            "first_partial_ms": round(current.first_partial_ms, 1)
            if current.first_partial_ms is not None
            else None,
            "final_decode_ms": round(final_ms, 1),
            "max_partial_decode_ms": round(current.max_partial_ms, 1),
            "partials": len(current.partials),
            "session_ms": round((time.monotonic() - t_start) * 1000.0, 1),
        }
        info = {
            "latency_ms": latency,
            "reason": reason,
            "session_id": self.session_id,
            "text_source": source,
            "decode_attempts": attempts,
            "audio_s": round(len(audio) / rate, 3),
            "raw_audio_s": round(raw_duration, 3),
            "noise_floor_db": round(endpointer.floor_db, 1),
        }
        entry_id = self.dataset.add_utterance(
            audio,
            text,
            partials=current.partials,
            info=info,
            segment_index=current.index,
            is_last=last,
            source="file" if self.source_file else "mic",
        )
        self.on_segment(
            Segment(
                text=text,
                audio=audio,
                entry_id=entry_id,
                segment_index=current.index,
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
