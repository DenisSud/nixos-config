"""Speech onset / endpoint policy for one dictation session.

``AsrEngine.make_vad`` gives us a frame-level speech model (silero or
ten-vad).  A model is not a policy: silero's ``is_speech_detected()`` drops
right after its ``min_silence_duration``, which made the session end on the
first short pause and hand the decoder a chunk ending in dead air (that tail
is enough to make Parakeet's int8 transducer emit nothing at all).

This module adds the policy layer:

* adaptive noise floor, so thresholds follow the room instead of assuming a
  quiet one;
* energy gate on onset, so a VAD false positive in a noisy room does not
  start a session;
* hangover that is short in a clear pause and long when the tail is still
  noisy, plus a bonus while the running hypothesis is still changing (a
  pause in the middle of a sentence rarely comes with settled text);
* helpers to trim the silence we waited for before the final decode.

Everything here is pure numpy: no sherpa-onnx import, so it is cheap to test.
"""

from __future__ import annotations

import math
from enum import IntEnum

import numpy as np

from .config import Config

#: VAD model window size in samples at 16 kHz.
VAD_WINDOWS = {"silero": 512, "ten": 256}

#: The adaptive floor never leaves this range: below it is digital silence,
#: above it we would classify speech as background noise.
FLOOR_MIN_DB = -75.0
FLOOR_MAX_DB = -30.0
#: Typical quiet-room level for a close mic.  Starting here (instead of
#: digital silence) means the very first frames cannot pass the onset gate
#: just because the estimate has not settled yet.
FLOOR_INIT_DB = -55.0

#: Floor tracking rates while idle.  Downward is fast (the room really is
#: quiet now), upward is slow (do not chase a door slam or a cough).
FLOOR_FAST = 0.10
FLOOR_SLOW = 0.01

#: How fast the speech loudness reference decays while speaking, dB/frame.
SPEECH_DB_DECAY = 0.05

#: How fast the level of the trailing silence decays, dB/frame (50 dB/s).
SILENCE_PEAK_DECAY = 1.0

#: A tail is "quiet" when it is this far below the speech reference level.
SPEECH_REF_DROP_DB = 18.0


class Event(IntEnum):
    IDLE = 0      # no speech yet
    ONSET = 1     # speech starts with this frame
    SPEECH = 2    # speech (or a pause shorter than the hangover)
    END = 3       # endpoint reached with this frame


def frame_db(frame: np.ndarray) -> float:
    """RMS level of one frame in dBFS (clamped at -80 dB)."""
    if frame.size == 0:
        return FLOOR_MIN_DB
    rms = float(np.sqrt(np.mean(np.square(frame, dtype=np.float64))))
    return 20.0 * math.log10(max(rms, 1e-8))


class Endpointer:
    def __init__(self, cfg: Config, vad) -> None:
        self.cfg = cfg
        self.vad = vad
        self.sample_rate = int(cfg.sample_rate)
        self.window = VAD_WINDOWS.get(cfg.vad_model, 512)
        self._vad_buf = np.zeros(0, dtype=np.float32)

        self.floor_db = FLOOR_INIT_DB
        self.speech_db = FLOOR_MIN_DB
        self.in_speech = False
        self.silence_s = 0.0
        self.silence_peak_db = FLOOR_MIN_DB
        self.speech_s = 0.0
        self.last_db = FLOOR_MIN_DB
        self.partial_changed_at = -1e9

    # -- public API -----------------------------------------------------
    def push(self, frame: np.ndarray, now: float) -> Event:
        """Feed one 20 ms frame and classify it."""
        db = frame_db(frame)
        self.last_db = db
        self._feed_vad(frame)
        vad_says = bool(self.vad.is_speech_detected())
        frame_s = len(frame) / self.sample_rate

        if not self.in_speech:
            self._adapt_floor(db, vad_says)
            if vad_says and db - self.floor_db >= self.cfg.onset_snr:
                self.in_speech = True
                self.speech_s = 0.0
                self.silence_s = 0.0
                self.speech_db = db
                return Event.ONSET
            return Event.IDLE

        self.speech_s += frame_s
        self.speech_db = max(db, self.speech_db - SPEECH_DB_DECAY)
        if vad_says:
            self.silence_s = 0.0
            self.silence_peak_db = FLOOR_MIN_DB
            return Event.SPEECH

        self.silence_s += frame_s
        self.silence_peak_db = max(db, self.silence_peak_db - SILENCE_PEAK_DECAY)
        if self.silence_s >= self._hangover(now):
            # One dictation per session: further frames are idle again.
            self.in_speech = False
            self.silence_s = 0.0
            self.silence_peak_db = FLOOR_MIN_DB
            return Event.END
        return Event.SPEECH

    def mark_partial(self, text: str, now: float) -> None:
        """Remember that the running hypothesis just changed."""
        if text:
            self.partial_changed_at = now

    def drain_vad(self) -> None:
        """Drop completed VAD segments (we keep our own audio buffer)."""
        while not self.vad.empty():
            self.vad.pop()

    def trim(
        self,
        audio: np.ndarray,
        *,
        lead_pad: float | None = None,
        tail_pad: float | None = None,
    ) -> np.ndarray:
        """Cut leading/trailing non-speech, keeping a small pad on each side."""
        cfg = self.cfg
        lead_pad = cfg.lead_pad if lead_pad is None else lead_pad
        tail_pad = cfg.tail_pad if tail_pad is None else tail_pad
        n = cfg.frame_samples
        if len(audio) < 2 * n:
            return audio

        threshold = self.silence_threshold_db
        levels = [
            frame_db(audio[i : i + n]) for i in range(0, len(audio) - n + 1, n)
        ]
        loud = [i for i, db in enumerate(levels) if db >= threshold]
        if not loud:
            return audio  # cannot classify it; better to decode what we have

        rate = self.sample_rate
        start = max(0, loud[0] * n - int(lead_pad * rate))
        end = min(len(audio), (loud[-1] + 1) * n + int(tail_pad * rate))
        return audio[start:end]

    def first_loud(self, frames: list[np.ndarray]) -> int:
        """Index of the first pre-roll frame that belongs to the onset.

        VAD onset lags the acoustic onset by its ``min_speech_duration``;
        dropping the dead leading frames keeps the first decode small without
        clipping the first syllable.
        """
        threshold = self.silence_threshold_db
        keep = int(self.cfg.lead_pad * self.sample_rate)
        kept = 0
        index = len(frames) - 1
        for i in range(len(frames) - 1, -1, -1):
            index = i
            if frame_db(frames[i]) >= threshold:
                kept = 0
            else:
                kept += len(frames[i])
                if kept > keep:
                    index = i + 1
                    break
        return min(index, len(frames) - 1)

    # -- internals ------------------------------------------------------
    @property
    def silence_threshold_db(self) -> float:
        """Level below which a frame counts as non-speech.

        The lower of "near the room floor" and "well below the speaker's own
        level", so it follows both a quiet mic and a loud one.
        """
        return min(
            self.floor_db + self.cfg.quiet_snr,
            self.speech_db - SPEECH_REF_DROP_DB,
        )

    def _hangover(self, now: float) -> float:
        cfg = self.cfg
        hang = (
            cfg.end_silence
            if self.silence_peak_db < self.silence_threshold_db
            else cfg.end_silence_noisy
        )
        if now - self.partial_changed_at < cfg.partial_grace:
            hang += cfg.pause_grace
        return hang

    def _adapt_floor(self, db: float, vad_says: bool) -> None:
        if db < self.floor_db:
            rate = FLOOR_FAST
        elif vad_says:
            # Never let speech pull the floor up; that would make the next
            # onset in the same session progressively harder to detect.
            return
        else:
            rate = FLOOR_SLOW
        floor = self.floor_db + rate * (db - self.floor_db)
        self.floor_db = min(max(floor, FLOOR_MIN_DB), FLOOR_MAX_DB)

    def _feed_vad(self, frame: np.ndarray) -> None:
        self._vad_buf = np.concatenate((self._vad_buf, frame))
        while len(self._vad_buf) >= self.window:
            self.vad.accept_waveform(self._vad_buf[: self.window])
            self._vad_buf = self._vad_buf[self.window :]
        self.drain_vad()


def looks_degenerate(text: str, *, min_repeats: int = 4, max_unit: int = 8) -> bool:
    """True for transducer loops such as ``Hehehehehehe``.

    Parakeet occasionally degenerates into a repeated short unit when the
    input is noise or music.  Committing that is worse than committing the
    last partial hypothesis.
    """
    compact = "".join(text.split()).lower()
    n = len(compact)
    if n < 12:
        return False
    for unit in range(1, min(max_unit, n // min_repeats) + 1):
        chunk = compact[:unit]
        if chunk and compact.startswith(chunk * (n // unit)):
            return True
    return False
