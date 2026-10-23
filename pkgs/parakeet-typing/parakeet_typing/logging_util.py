"""Logging setup: a rotating debug log plus stderr when explicitly requested."""

from __future__ import annotations

import logging
import logging.handlers
from pathlib import Path

from .config import APP, Config

_configured = False


def setup_logging(cfg: Config, *, stderr: bool | None = None) -> logging.Logger:
    global _configured
    logger = logging.getLogger(APP)
    if _configured:
        return logger

    logger.setLevel(logging.DEBUG)
    logger.propagate = False

    log_dir = Path(cfg.state_dir) / "log"
    log_dir.mkdir(parents=True, exist_ok=True)
    handler = logging.handlers.RotatingFileHandler(
        log_dir / "parakeet-typing.log",
        maxBytes=1_000_000,
        backupCount=2,
        encoding="utf-8",
    )
    handler.setFormatter(
        logging.Formatter("%(asctime)s %(levelname)-7s %(name)s: %(message)s")
    )
    logger.addHandler(handler)

    if stderr is None:
        stderr = bool(__import__("os").environ.get("PARAKEET_TYPING_DEBUG"))
    if stderr:
        console = logging.StreamHandler()
        console.setFormatter(logging.Formatter("%(levelname)s %(message)s"))
        logger.addHandler(console)

    _configured = True
    return logger


def log_path(cfg: Config) -> Path:
    return Path(cfg.state_dir) / "log" / "parakeet-typing.log"
