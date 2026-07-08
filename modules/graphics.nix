{
  # ── Graphics / Hardware ───────────────────────────────
  hardware = {
    i2c.enable = true;
    graphics = {
      enable = true;
      enable32Bit = true;
    };

    # NVIDIA Container Toolkit — needed for CUDA inside Docker
    # on NVIDIA-equipped hosts. Harmless on non-NVIDIA boxes
    # (just installs the toolkit, doesn't pull a driver).
    nvidia-container-toolkit.enable = true;
  };
}
