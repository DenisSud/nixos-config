{ config, pkgs, ... }:

{
  # ── Host Identity ─────────────────────────────────────
  networking.hostName = "g14";

  # ── NVIDIA (ROG Zephyrus G14 — hybrid graphics) ───────
  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
  };

  services.xserver.videoDrivers = [ "nvidia" "amdgpu" ];
}