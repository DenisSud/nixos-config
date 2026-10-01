{
  config,
  lib,
  ...
}:

let
  cfg = config.denis.docker;
in
{
  options.denis.docker.enable = lib.mkEnableOption "Docker (with the NVIDIA container toolkit)";

  config = lib.mkIf cfg.enable {
    # ── Docker ──────────────────────────────────────────
    # PC-only — laptop uses no container runtime to stay lite.
    virtualisation.docker.enable = true;

    # NVIDIA Container Toolkit — needed for CUDA inside Docker.
    hardware.nvidia-container-toolkit.enable = true;
  };
}
