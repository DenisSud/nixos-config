"""Runtime configuration for parakeet-typing.

Everything has a sane default; optional overrides live in
``$XDG_CONFIG_HOME/parakeet-typing/config.json``.  The Nix wrapper bakes
``PARAKEET_TYPING_MODEL_DIR`` (the read-only model in the Nix store) and the
absolute paths of the external programs we shell out to.
"""

from __future__ import annotations

import json
import logging
import os
import tempfile
from dataclasses import dataclass, fields
from pathlib import Path

APP = "parakeet-typing"


def _xdg(env: str, fallback: str) -> Path:
    value = os.environ.get(env)
    if value:
        return Path(value)
    return Path.home() / fallback


DATA_HOME = _xdg("XDG_DATA_HOME", ".local/share") / APP
STATE_HOME = _xdg("XDG_STATE_HOME", ".local/state") / APP
CONFIG_HOME = _xdg("XDG_CONFIG_HOME", ".config") / APP
RUNTIME_DIR = Path(os.environ.get("XDG_RUNTIME_DIR") or tempfile.gettempdir())
SOCKET_PATH = RUNTIME_DIR / f"{APP}-{os.getuid()}.sock"
PENDING_PATH = RUNTIME_DIR / f"{APP}-{os.getuid()}.pending"
CONFIG_PATH = CONFIG_HOME / "config.json"

#: Keys that are valid in config.json.  Keeping this explicit turns typos
#: into a warning instead of a silently ignored setting.
_CONFIG_KEYS = {
    "num_threads",
    "partial_interval",
    "partial_min_audio",
    "end_silence",
    "end_silence_noisy",
    "onset_snr",
    "quiet_snr",
    "pause_grace",
    "partial_grace",
    "tail_pad",
    "lead_pad",
    "min_speech",
    "pre_roll",
    "max_utterance",
    "vad_model",
    "vad_threshold",
    "vad_min_silence",
    "log_audio",
    "log_partials",
    "correction_window",
    "idle_timeout",
    "hotkey",
    "pw_record",
    "pw_play",
    "ibus",
    "model_dir",
}


@dataclass
class Config:
    # ASR / audio
    sample_rate: int = 16_000
    frame_ms: int = 20
    num_threads: int = 4
    partial_interval: float = 0.35
    partial_min_audio: float = 0.35
    min_speech: float = 0.20
    pre_roll: float = 0.60
    max_utterance: float = 20.0
    idle_timeout: float = 30.0

    # Endpointing (see parakeet_typing/endpoint.py)
    vad_model: str = "silero"          # "silero" | "ten"
    vad_threshold: float = 0.45
    vad_min_silence: float = 0.25     # VAD segmenter; the hangover is the policy
    end_silence: float = 0.60         # hangover after a clearly quiet pause
    end_silence_noisy: float = 1.20   # hangover while the tail is still noisy
    onset_snr: float = 6.0            # dB above the noise floor to start
    quiet_snr: float = 9.0            # dB above the floor that counts as quiet
    pause_grace: float = 0.25         # extra hangover for a fresh hypothesis
    partial_grace: float = 0.70       # ... "fresh" means changed this recently
    tail_pad: float = 0.15            # audio kept after the last speech frame
    lead_pad: float = 0.10            # ... and before the first one

    # Dataset
    log_audio: bool = True
    log_partials: bool = True

    # Post-commit correction tracking (0 disables it and restores the input
    # source immediately after committing).
    correction_window: float = 15.0

    # GNOME integration
    hotkey: str = "<Super><Alt>v"

    # Debug: feed a WAV file instead of the microphone (used by tests and
    # the `stream` command; the engine honours it too when explicitly set).
    source_file: str | None = None

    # Paths / commands (overridable)
    model_dir: Path = DATA_HOME / "model"
    pw_record: str = "pw-record"
    pw_play: str = "pw-play"
    ibus: str = "ibus"

    # Fixed locations
    data_dir: Path = DATA_HOME
    state_dir: Path = STATE_HOME
    config_path: Path = CONFIG_PATH
    socket_path: Path = SOCKET_PATH
    pending_path: Path = PENDING_PATH

    @property
    def frame_samples(self) -> int:
        return self.sample_rate * self.frame_ms // 1000

    def ensure_dirs(self) -> None:
        self.data_dir.mkdir(parents=True, exist_ok=True)
        self.state_dir.mkdir(parents=True, exist_ok=True)
        (self.data_dir / "audio").mkdir(parents=True, exist_ok=True)

    @classmethod
    def load(cls) -> "Config":
        cfg = cls()

        # Nix wrapper / environment wins over the JSON file so that a store
        # path change (rebuild) is always picked up.
        env_model = os.environ.get("PARAKEET_TYPING_MODEL_DIR")
        if env_model:
            cfg.model_dir = Path(env_model)
        env_record = os.environ.get("PARAKEET_TYPING_PW_RECORD")
        if env_record:
            cfg.pw_record = env_record
        env_play = os.environ.get("PARAKEET_TYPING_PW_PLAY")
        if env_play:
            cfg.pw_play = env_play
        env_ibus = os.environ.get("PARAKEET_TYPING_IBUS")
        if env_ibus:
            cfg.ibus = env_ibus
        env_source = os.environ.get("PARAKEET_TYPING_SOURCE_FILE")
        if env_source:
            cfg.source_file = env_source

        if CONFIG_PATH.exists():
            try:
                raw = json.loads(CONFIG_PATH.read_text(encoding="utf-8"))
            except (OSError, json.JSONDecodeError) as exc:
                logging.getLogger(APP).warning(
                    "ignoring %s: %s", CONFIG_PATH, exc
                )
                raw = {}
            for key, value in raw.items():
                if key not in _CONFIG_KEYS:
                    logging.getLogger(APP).warning(
                        "unknown config key %r in %s", key, CONFIG_PATH
                    )
                    continue
                if key in ("pw_record", "pw_play", "ibus", "hotkey", "vad_model"):
                    setattr(cfg, key, str(value))
                elif key == "model_dir":
                    cfg.model_dir = Path(value).expanduser()
                elif isinstance(value, bool):
                    setattr(cfg, key, value)
                else:
                    try:
                        setattr(cfg, key, type(getattr(cfg, key))(value))
                    except (TypeError, ValueError):
                        logging.getLogger(APP).warning(
                            "bad value for %r in %s", key, CONFIG_PATH
                        )

        # Re-apply env overrides (they are authoritative).
        if env_model:
            cfg.model_dir = Path(env_model)
        if env_record:
            cfg.pw_record = env_record
        if env_play:
            cfg.pw_play = env_play
        if env_ibus:
            cfg.ibus = env_ibus

        cfg.ensure_dirs()
        return cfg

    def status(self) -> dict:
        """A JSON-serialisable subset for `parakeet-typing status`."""
        return {
            "model_dir": str(self.model_dir),
            "num_threads": self.num_threads,
            "partial_interval": self.partial_interval,
            "vad_model": self.vad_model,
            "vad_threshold": self.vad_threshold,
            "end_silence": self.end_silence,
            "end_silence_noisy": self.end_silence_noisy,
            "onset_snr": self.onset_snr,
            "correction_window": self.correction_window,
            "hotkey": self.hotkey,
            "source_file": self.source_file,
            "data_dir": str(self.data_dir),
            "socket_path": str(self.socket_path),
        }


def field_names() -> set[str]:
    return {f.name for f in fields(Config)}
