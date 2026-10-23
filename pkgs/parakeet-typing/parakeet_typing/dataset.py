"""Append-only dictation dataset.

Every committed utterance is stored as a 16 kHz mono WAV plus one JSON line
in ``utterances.jsonl``.  Post-commit edits made in the target application
are appended to ``corrections.jsonl`` and can later be reviewed and exported
as a Hugging Face style ASR dataset.

The layout is deliberately boring (plain files, one record per line) so that
an interrupted session never corrupts earlier samples and so the data can be
inspected with jq.
"""

from __future__ import annotations

import json
import logging
import secrets
import threading
import time
import wave
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Iterator

import numpy as np

from .config import Config

log = logging.getLogger("parakeet-typing.dataset")


def _now_iso() -> str:
    return datetime.now(timezone.utc).astimezone().isoformat(timespec="seconds")


class Dataset:
    def __init__(self, cfg: Config) -> None:
        self.cfg = cfg
        self.root = Path(cfg.data_dir)
        self.audio_dir = self.root / "audio"
        self.utterances_path = self.root / "utterances.jsonl"
        self.corrections_path = self.root / "corrections.jsonl"
        self._lock = threading.Lock()
        self.audio_dir.mkdir(parents=True, exist_ok=True)

    # -- writes ---------------------------------------------------------
    def add_utterance(
        self,
        audio: np.ndarray,
        text: str,
        *,
        partials: list[str],
        info: dict[str, Any],
        segment_index: int = 0,
        is_last: bool = True,
        source: str = "mic",
    ) -> str:
        ts = datetime.now(timezone.utc)
        entry_id = ts.strftime("%Y%m%dT%H%M%SZ") + "-" + secrets.token_hex(3)
        rel_audio = (
            Path("audio")
            / ts.strftime("%Y")
            / ts.strftime("%m")
            / ts.strftime("%d")
            / f"{entry_id}.wav"
        )
        audio_abs = self.root / rel_audio

        if self.cfg.log_audio:
            audio_abs.parent.mkdir(parents=True, exist_ok=True)
            self._write_wav(audio_abs, audio)

        entry = {
            "id": entry_id,
            "created_at": _now_iso(),
            "audio": str(rel_audio) if self.cfg.log_audio else None,
            "duration_s": round(len(audio) / self.cfg.sample_rate, 3),
            "text": text,
            "partials": partials if self.cfg.log_partials else [],
            "model": "parakeet-tdt-0.6b-v3-int8",
            "segment_index": segment_index,
            "is_last_segment": is_last,
            "source": source,
            "settings": {
                "end_silence": self.cfg.end_silence,
                "partial_interval": self.cfg.partial_interval,
                "pre_roll": self.cfg.pre_roll,
                "max_utterance": self.cfg.max_utterance,
                "vad_threshold": self.cfg.vad_threshold,
            },
            **info,
        }
        with self._lock:
            with self.utterances_path.open("a", encoding="utf-8") as fh:
                fh.write(json.dumps(entry, ensure_ascii=False) + "\n")
        log.info(
            "logged utterance %s (%.2fs, %d chars)",
            entry_id,
            entry["duration_s"],
            len(text),
        )
        return entry_id

    def add_correction(
        self,
        entry_id: str,
        *,
        committed_text: str,
        final_text: str,
        reliable: bool,
        edited: bool,
        events: list[dict[str, Any]],
        reason: str,
        appended_chars: int = 0,
    ) -> None:
        record = {
            "id": entry_id,
            "created_at": _now_iso(),
            "committed_text": committed_text,
            "final_text": final_text,
            "edited": edited,
            "reliable": reliable,
            "appended_chars": appended_chars,
            "reason": reason,
            "events": events,
        }
        with self._lock:
            with self.corrections_path.open("a", encoding="utf-8") as fh:
                fh.write(json.dumps(record, ensure_ascii=False) + "\n")
        log.info(
            "correction for %s: edited=%s reliable=%s reason=%s",
            entry_id,
            edited,
            reliable,
            reason,
        )

    @staticmethod
    def _write_wav(path: Path, samples: np.ndarray) -> None:
        pcm = np.clip(samples, -1.0, 1.0)
        pcm = (pcm * 32767.0).astype(np.int16)
        with wave.open(str(path), "wb") as wav:
            wav.setnchannels(1)
            wav.setsampwidth(2)
            wav.setframerate(16000)
            wav.writeframes(pcm.tobytes())

    # -- reads ----------------------------------------------------------
    def entries(self) -> Iterator[dict[str, Any]]:
        if not self.utterances_path.exists():
            return
        with self.utterances_path.open("r", encoding="utf-8") as fh:
            for line in fh:
                line = line.strip()
                if not line:
                    continue
                try:
                    yield json.loads(line)
                except json.JSONDecodeError:
                    log.warning("skipping malformed dataset line")

    def corrections(self) -> dict[str, dict[str, Any]]:
        latest: dict[str, dict[str, Any]] = {}
        if not self.corrections_path.exists():
            return latest
        with self.corrections_path.open("r", encoding="utf-8") as fh:
            for line in fh:
                try:
                    rec = json.loads(line)
                except json.JSONDecodeError:
                    continue
                if "id" in rec:
                    latest[rec["id"]] = rec
        return latest

    def merged(self) -> list[dict[str, Any]]:
        corrections = self.corrections()
        out: list[dict[str, Any]] = []
        for entry in self.entries():
            corr = corrections.get(entry["id"])
            entry = dict(entry)
            if corr:
                entry["corrected_text"] = corr.get("final_text")
                entry["correction"] = corr
            out.append(entry)
        return out

    def audio_path(self, entry: dict[str, Any]) -> Path | None:
        rel = entry.get("audio")
        if not rel:
            return None
        path = self.root / rel
        return path if path.is_file() else None

    def stats(self) -> dict[str, Any]:
        entries = list(self.entries())
        corrections = self.corrections()
        audio_bytes = 0
        for entry in entries:
            path = self.audio_path(entry)
            if path:
                try:
                    audio_bytes += path.stat().st_size
                except OSError:
                    pass
        return {
            "utterances": len(entries),
            "corrected": len(corrections),
            "audio_bytes": audio_bytes,
            "data_dir": str(self.root),
            "last_entry": entries[-1]["created_at"] if entries else None,
        }


def sleep_until(deadline: float) -> None:
    """Small helper used by tests and the file-streaming debug command."""
    delay = deadline - time.monotonic()
    if delay > 0:
        time.sleep(delay)


class NullDataset(Dataset):
    """Dataset sink used by `parakeet-typing stream` (debug runs)."""

    def __init__(self) -> None:  # noqa: D107 - deliberately skips setup
        self._lock = threading.Lock()

    def add_utterance(  # type: ignore[override]
        self,
        audio: np.ndarray,
        text: str,
        *,
        partials: list[str],
        info: dict[str, Any],
        segment_index: int = 0,
        is_last: bool = True,
        source: str = "mic",
    ) -> str:
        return f"debug-{segment_index}"

    def add_correction(self, *args: Any, **kwargs: Any) -> None:  # type: ignore[override]
        return None

    def stats(self) -> dict[str, Any]:  # type: ignore[override]
        return {}
