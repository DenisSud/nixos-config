{
  # ── Docker ────────────────────────────────────────────
  # PC-only — laptop uses no container runtime to stay lite.
  virtualisation.docker.enable = true;

  # NVIDIA Container Toolkit — needed for CUDA inside Docker.
  hardware.nvidia-container-toolkit.enable = true;
}
