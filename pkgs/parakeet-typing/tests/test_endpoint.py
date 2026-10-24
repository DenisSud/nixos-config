"""Unit tests for the endpoint policy (no model, no audio hardware).

Run with: ``python -m unittest discover -s tests``
"""

from __future__ import annotations

import unittest

import numpy as np

from parakeet_typing.config import Config
from parakeet_typing.endpoint import Endpointer, Event, looks_degenerate

RATE = 16_000
FRAME = 320  # 20 ms


class FakeVad:
    """Reports speech for the given (start, end) seconds of fed audio."""

    def __init__(self, speech: list[tuple[float, float]]) -> None:
        self.speech = speech
        self.samples = 0

    def accept_waveform(self, x: np.ndarray) -> None:
        self.samples += len(x)

    def is_speech_detected(self) -> bool:
        t = self.samples / RATE
        return any(start <= t < end for start, end in self.speech)

    def empty(self) -> bool:
        return True

    def pop(self) -> None:  # pragma: no cover - drained only when non-empty
        raise AssertionError("nothing to pop")


def tone(seconds: float, amplitude: float, freq: float = 180.0) -> np.ndarray:
    n = int(round(seconds * RATE))
    t = np.arange(n, dtype=np.float32) / RATE
    return (amplitude * np.sin(2 * np.pi * freq * t)).astype(np.float32)


def frames(audio: np.ndarray) -> list[np.ndarray]:
    return [audio[i : i + FRAME] for i in range(0, len(audio) - FRAME + 1, FRAME)]


def drive(endpointer: Endpointer, audio: np.ndarray, t0: float = 0.0):
    """Feed audio and return [(time, event), ...]."""
    events = []
    t = t0
    for frame in frames(audio):
        event = endpointer.push(frame, t)
        events.append((t, event))
        t += FRAME / RATE
    return events


SPEECH = 0.05  # ~ -29 dBFS RMS
QUIET = 0.001  # ~ -60 dBFS RMS
NOISE = 0.01  # ~ -40 dBFS RMS


class EndpointTest(unittest.TestCase):
    def make(self, **overrides) -> Config:
        cfg = Config(**overrides)
        cfg.sample_rate = RATE
        cfg.frame_ms = 20
        return cfg

    def test_onset_and_quiet_endpoint(self) -> None:
        cfg = self.make()
        vad = FakeVad([(0.5, 1.5)])
        ep = Endpointer(cfg, vad)
        audio = np.concatenate([tone(0.5, QUIET), tone(1.0, SPEECH), tone(2.0, QUIET)])
        events = drive(ep, audio)

        onsets = [t for t, e in events if e is Event.ONSET]
        ends = [t for t, e in events if e is Event.END]
        self.assertEqual(len(onsets), 1)
        self.assertLessEqual(onsets[0], 0.5 + 0.10, "onset should follow the VAD")
        self.assertEqual(len(ends), 1)
        # endpoint = speech end + end_silence (0.6 s), give or take a frame
        self.assertAlmostEqual(ends[0], 1.5 + cfg.end_silence, delta=0.08)

    def test_short_pause_does_not_end_the_session(self) -> None:
        cfg = self.make()
        pause = cfg.end_silence - 0.2  # 0.4 s
        vad = FakeVad([(0.2, 1.2), (1.2 + pause, 2.2 + pause)])
        ep = Endpointer(cfg, vad)
        audio = np.concatenate(
            [
                tone(0.2, QUIET),
                tone(1.0, SPEECH),
                tone(pause, QUIET),
                tone(1.0, SPEECH),
                tone(2.0, QUIET),
            ]
        )
        events = drive(ep, audio)
        self.assertEqual(sum(1 for _, e in events if e is Event.ONSET), 1)
        ends = [t for t, e in events if e is Event.END]
        self.assertEqual(len(ends), 1)
        self.assertAlmostEqual(ends[0], 2.6 + cfg.end_silence, delta=0.1)

    def test_noisy_tail_waits_longer(self) -> None:
        cfg = self.make()
        vad = FakeVad([(0.5, 1.5)])
        ep = Endpointer(cfg, vad)
        audio = np.concatenate([tone(0.5, QUIET), tone(1.0, SPEECH), tone(2.0, NOISE)])
        events = drive(ep, audio)
        ends = [t for t, e in events if e is Event.END]
        self.assertEqual(len(ends), 1)
        # The tail is above the "quiet" level, so the long hangover applies.
        self.assertAlmostEqual(ends[0], 1.5 + cfg.end_silence_noisy, delta=0.1)

    def test_energy_gate_rejects_vad_false_positive(self) -> None:
        cfg = self.make()
        vad = FakeVad([(0.0, 5.0)])  # VAD claims speech ...
        ep = Endpointer(cfg, vad)
        events = drive(ep, tone(2.0, QUIET))  # ... but the room is silent
        self.assertFalse(any(e is Event.ONSET for _, e in events))

    def test_fresh_hypothesis_extends_the_hangover(self) -> None:
        cfg = self.make()
        vad = FakeVad([(0.5, 1.5)])
        ep = Endpointer(cfg, vad)
        audio = np.concatenate([tone(0.5, QUIET), tone(1.0, SPEECH), tone(2.0, QUIET)])
        # Pretend the transcript was still changing 0.3 s after the speech
        # ended: mark it at t=1.8 as the loop reaches that frame.
        events = []
        t = 0.0
        for frame in frames(audio):
            if abs(t - 1.8) < 1e-6:
                ep.mark_partial("half a sentence", t)
            event = ep.push(frame, t)
            events.append((t, event))
            t += FRAME / RATE
        ends = [t for t, e in events if e is Event.END]
        self.assertEqual(len(ends), 1)
        self.assertAlmostEqual(
            ends[0], 1.5 + cfg.end_silence + cfg.pause_grace, delta=0.08
        )

    def test_trim_keeps_speech_and_pads(self) -> None:
        cfg = self.make()
        ep = Endpointer(cfg, FakeVad([(0.5, 1.5)]))
        audio = np.concatenate([tone(0.5, QUIET), tone(1.0, SPEECH), tone(2.0, QUIET)])
        drive(ep, audio)

        trimmed = ep.trim(audio)
        expected = 1.0 + cfg.lead_pad + cfg.tail_pad
        self.assertAlmostEqual(len(trimmed) / RATE, expected, delta=0.1)
        # The kept lead pad is silence; right after it the speech must start.
        first_speech = int(cfg.lead_pad * RATE)
        self.assertGreater(
            float(np.sqrt(np.mean(trimmed[first_speech : first_speech + FRAME] ** 2))),
            NOISE,
        )

    def test_trim_leaves_audio_without_known_speech_alone(self) -> None:
        cfg = self.make()
        ep = Endpointer(cfg, FakeVad([]))
        audio = tone(1.0, QUIET)
        trimmed = ep.trim(audio)
        self.assertEqual(len(trimmed), len(audio))
        np.testing.assert_array_equal(trimmed, audio)

    def test_first_loud_skips_dead_preroll(self) -> None:
        cfg = self.make()
        ep = Endpointer(cfg, FakeVad([(0.5, 1.5)]))
        audio = np.concatenate([tone(0.5, QUIET), tone(1.0, SPEECH)])
        drive(ep, audio)
        preroll = frames(audio)
        speech_frame = int(0.5 * RATE) // FRAME  # frame 25
        index = ep.first_loud(preroll)
        self.assertLessEqual(index, speech_frame)
        self.assertGreaterEqual(
            index, speech_frame - 7, "drops all but ~lead_pad of the dead pre-roll"
        )


class DegenerateTest(unittest.TestCase):
    def test_repeated_unit(self) -> None:
        self.assertTrue(looks_degenerate("Hehehehehehehehe"))
        self.assertTrue(looks_degenerate("лоллоллоллоллол"))
        self.assertTrue(looks_degenerate("5, 5, 5, 5, 5, 5, 5, 5"))

    def test_normal_text(self) -> None:
        self.assertFalse(looks_degenerate("Hello."))
        self.assertFalse(looks_degenerate("Uh, do you hear me?"))
        self.assertFalse(looks_degenerate("Четыре, пять, шесть, семь, восемь."))
        self.assertFalse(looks_degenerate(""))


if __name__ == "__main__":
    unittest.main()
