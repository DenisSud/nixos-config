"""Microphone capture.

Reads raw mono s16le from ``pw-record`` (PipeWire) and hands out fixed-size
float32 frames.  A file source is available for tests / the ``stream`` debug
command; it is paced in real time so the streaming path is exercised the same
way as with a microphone.
"""

from __future__ import annotations

import os
import select
import shutil
import subprocess
import time
import wave
from pathlib import Path

import numpy as np

from .config import Config


class CaptureError(RuntimeError):
    pass


class EndOfStream(RuntimeError):
    pass


class AudioCapture:
    def __init__(
        self,
        cfg: Config,
        *,
        source_file: str | Path | None = None,
        pace: bool = True,
    ) -> None:
        self.cfg = cfg
        self.frame_samples = cfg.frame_samples
        self.source_file = Path(source_file) if source_file else None
        self.pace = pace

        self._proc: subprocess.Popen[bytes] | None = None
        self._fd: int | None = None
        self._pending = np.zeros(0, dtype=np.float32)
        self._pending_bytes = b""
        self._file_frames: np.ndarray | None = None
        self._file_pos = 0
        self._next_emit = 0.0
        self._closed = False

    # -- public API -----------------------------------------------------
    def start(self) -> None:
        if self.source_file:
            self._load_file(self.source_file)
            return

        exe = shutil.which(self.cfg.pw_record) or self.cfg.pw_record
        cmd = [
            exe,
            "--raw",
            "--format=s16",
            "--rate=16000",
            "--channels=1",
            "--latency=20ms",
        ]
        # `-` writes raw PCM to stdout.
        cmd.append("-")
        self._proc = subprocess.Popen(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            bufsize=0,
        )
        assert self._proc.stdout is not None
        self._fd = self._proc.stdout.fileno()
        os.set_blocking(self._fd, False)

    def read(self) -> np.ndarray | None:
        """Return exactly ``frame_samples`` float32 samples, or None on timeout."""
        if self._closed:
            raise EndOfStream()
        if self.source_file:
            return self._read_file()
        return self._read_pipe()

    def close(self) -> None:
        if self._closed:
            return
        self._closed = True
        proc = self._proc
        self._proc = None
        self._fd = None
        if proc is None:
            return
        try:
            proc.terminate()
            proc.wait(timeout=2)
        except (subprocess.TimeoutExpired, OSError):
            try:
                proc.kill()
            except OSError:
                pass

    # -- microphone -----------------------------------------------------
    def _read_pipe(self) -> np.ndarray | None:
        need = self.frame_samples
        while len(self._pending) < need:
            assert self._fd is not None and self._proc is not None
            ready, _, _ = select.select([self._fd], [], [], 0.10)
            if not ready:
                if self._proc.poll() is not None:
                    raise CaptureError(
                        f"{self.cfg.pw_record} exited with {self._proc.returncode}"
                    )
                return None
            try:
                chunk = os.read(self._fd, need * 2 * 8)
            except BlockingIOError:
                continue
            except OSError as exc:
                raise CaptureError(f"microphone read failed: {exc}") from exc
            if not chunk:
                raise CaptureError("microphone stream ended")
            # PipeWire writes frame-aligned blocks, but os.read() can still
            # return an odd byte count; only convert whole int16 samples.
            self._pending_bytes += chunk
            usable = len(self._pending_bytes) - (len(self._pending_bytes) % 2)
            if usable:
                samples = np.frombuffer(
                    self._pending_bytes[:usable], dtype=np.int16
                ).astype(np.float32)
                self._pending_bytes = self._pending_bytes[usable:]
                self._pending = np.concatenate([self._pending, samples / 32768.0])

        frame = self._pending[:need]
        self._pending = self._pending[need:]
        return frame

    # -- file source (tests / debug) ------------------------------------
    def _load_file(self, path: Path) -> None:
        with wave.open(str(path), "rb") as wav:
            if wav.getsampwidth() != 2:
                raise CaptureError("only 16-bit WAV files are supported")
            channels = wav.getnchannels()
            rate = wav.getframerate()
            raw = wav.readframes(wav.getnframes())
        samples = np.frombuffer(raw, dtype=np.int16).astype(np.float32) / 32768.0
        if channels > 1:
            samples = samples.reshape(-1, channels).mean(axis=1)
        if rate != self.cfg.sample_rate:
            n = int(round(len(samples) * self.cfg.sample_rate / rate))
            x_old = np.arange(len(samples), dtype=np.float64)
            x_new = np.linspace(0, len(samples) - 1, n)
            samples = np.interp(x_new, x_old, samples).astype(np.float32)
        self._file_frames = samples
        self._next_emit = time.monotonic()

    def _read_file(self) -> np.ndarray | None:
        assert self._file_frames is not None
        need = self.frame_samples
        if self._file_pos + need > len(self._file_frames):
            raise EndOfStream()
        if self.pace:
            now = time.monotonic()
            if now < self._next_emit:
                time.sleep(self._next_emit - now)
            self._next_emit += need / self.cfg.sample_rate
        frame = self._file_frames[self._file_pos : self._file_pos + need]
        self._file_pos += need
        return frame
