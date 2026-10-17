{
  config,
  lib,
  ...
}:

let
  cfgDocker = config.denis.docker;
  cfgPodman = config.denis.podman;
in
{
  options.denis.docker.enable = lib.mkEnableOption "Docker (with the NVIDIA container toolkit)";
  options.denis.podman.enable = lib.mkEnableOption "Podman (container runtime)";

  config = lib.mkMerge [
    (lib.mkIf cfgDocker.enable {
      # ── Docker ──────────────────────────────────────────
      # PC-only — laptop uses no container runtime to stay lite.
      virtualisation.docker.enable = true;

      # NVIDIA Container Toolkit — needed for CUDA inside Docker.
      hardware.nvidia-container-toolkit.enable = true;
    })

    (lib.mkIf cfgPodman.enable {
      # ── Podman ──────────────────────────────────────────
      # Runs the Phonon-2 dictation container declared via
      # virtualisation.oci-containers in hosts/pc.nix.
      virtualisation.podman.enable = true;
    })
  ];
}
