"""Parakeet TDT v3 inference via sherpa-onnx (CPU, int8).

The same recognizer instance is reused for every partial and final decode.
Only the session worker thread calls into it, so the recognizer itself needs
no locking; ``load()`` is guarded because the control socket may ask for the
status while the first activation is still loading the model.
"""

from __future__ import annotations

import logging
import threading
import time
from pathlib import Path

import numpy as np

from .config import Config

MODEL_FILES = (
    "encoder.int8.onnx",
    "decoder.int8.onnx",
    "joiner.int8.onnx",
    "tokens.txt",
)

#: VAD model per `vad_model` setting.  Both ship with the package; silero is
#: the default, ten-vad is 129 kB int8 and can be selected in config.json.
VAD_FILES = {
    "silero": "silero_vad.onnx",
    "ten": "ten-vad.int8.onnx",
}

MODEL_NAME = "parakeet-tdt-0.6b-v3-int8"


class AsrError(RuntimeError):
    pass


class AsrEngine:
    def __init__(self, cfg: Config, logger: logging.Logger) -> None:
        self.cfg = cfg
        self.log = logger
        self._rec = None
        self._lock = threading.Lock()

    @property
    def loaded(self) -> bool:
        return self._rec is not None

    def model_paths(self) -> dict[str, Path]:
        model_dir = Path(self.cfg.model_dir)
        paths = {name: model_dir / name for name in MODEL_FILES}
        missing = [str(p) for p in paths.values() if not p.is_file()]
        if missing:
            raise AsrError(
                "model files missing in %s: %s" % (model_dir, ", ".join(missing))
            )
        return paths

    def vad_path(self) -> Path:
        name = VAD_FILES.get(self.cfg.vad_model)
        if name is None:
            raise AsrError(
                "unknown vad_model %r (expected one of %s)"
                % (self.cfg.vad_model, ", ".join(sorted(VAD_FILES)))
            )
        path = Path(self.cfg.model_dir) / name
        if not path.is_file():
            raise AsrError("VAD model missing: %s" % path)
        return path

    def load(self) -> None:
        if self._rec is not None:
            return
        with self._lock:
            if self._rec is not None:
                return
            import sherpa_onnx  # imported lazily: keeps `--help` fast

            paths = self.model_paths()
            t0 = time.monotonic()
            self._rec = sherpa_onnx.OfflineRecognizer.from_transducer(
                encoder=str(paths["encoder.int8.onnx"]),
                decoder=str(paths["decoder.int8.onnx"]),
                joiner=str(paths["joiner.int8.onnx"]),
                tokens=str(paths["tokens.txt"]),
                model_type="nemo_transducer",
                decoding_method="greedy_search",
                num_threads=int(self.cfg.num_threads),
                sample_rate=int(self.cfg.sample_rate),
                feature_dim=80,
                provider="cpu",
            )
            self.log.info(
                "loaded %s from %s in %.0f ms",
                MODEL_NAME,
                self.cfg.model_dir,
                (time.monotonic() - t0) * 1000,
            )

    def unload(self) -> None:
        with self._lock:
            self._rec = None
        self.log.info("recognizer unloaded")

    def transcribe(self, samples: np.ndarray) -> tuple[str, float]:
        if self._rec is None:
            self.load()
        assert self._rec is not None
        audio = np.asarray(samples, dtype=np.float32)
        if audio.size == 0:
            return "", 0.0
        audio = np.clip(audio, -1.0, 1.0)
        t0 = time.monotonic()
        stream = self._rec.create_stream()
        stream.accept_waveform(int(self.cfg.sample_rate), audio)
        self._rec.decode_stream(stream)
        text = (stream.result.text or "").strip()
        return text, (time.monotonic() - t0) * 1000.0

    def make_vad(self):
        """Create a fresh VAD instance for one dictation session.

        The model only answers "is this frame speech"; when a dictation ends
        is decided by `endpoint.Endpointer`.  Its own segmenter is therefore
        set to a short silence duration.
        """
        import sherpa_onnx

        path = str(self.vad_path())
        vad_cfg = sherpa_onnx.VadModelConfig()
        if self.cfg.vad_model == "ten":
            vad_cfg.ten_vad.model = path
            vad_cfg.ten_vad.threshold = float(self.cfg.vad_threshold)
            vad_cfg.ten_vad.min_silence_duration = float(self.cfg.vad_min_silence)
            vad_cfg.ten_vad.min_speech_duration = float(self.cfg.min_speech)
            vad_cfg.ten_vad.max_speech_duration = float(
                max(30.0, self.cfg.max_utterance + 10.0)
            )
        else:
            vad_cfg.silero_vad.model = path
            vad_cfg.silero_vad.threshold = float(self.cfg.vad_threshold)
            vad_cfg.silero_vad.min_silence_duration = float(self.cfg.vad_min_silence)
            vad_cfg.silero_vad.min_speech_duration = float(self.cfg.min_speech)
            vad_cfg.silero_vad.max_speech_duration = float(
                max(30.0, self.cfg.max_utterance + 10.0)
            )
        vad_cfg.sample_rate = int(self.cfg.sample_rate)
        vad_cfg.num_threads = 1
        vad_cfg.provider = "cpu"
        vad_cfg.debug = False
        return sherpa_onnx.VoiceActivityDetector(
            vad_cfg,
            buffer_size_in_seconds=int(max(60, self.cfg.max_utterance + 20)),
        )
