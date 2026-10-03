{
  pkgs,
  ...
}:

{
  # ╔══════════════════════════════════════════════════════════╗
  # ║  PC — Desktop (AMD Ryzen + NVIDIA RTX 5070 / Blackwell)  ║
  # ╚══════════════════════════════════════════════════════════╝
  # Thin host: imports the shared layer and sets `denis.*` values.
  # Hardware-specific bits (NVIDIA, file systems) stay below.
  imports = [ ../modules/shared.nix ];

  # ── Host identity ─────────────────────────────────────
  denis.hostName = "pc";

  # ── Firewall: kept off on pc ─────────────────────────
  # Flipped off 2026-08-31 ("temporarily disabled") and never reverted.
  # Turning it on needs the LAN ports opened first, e.g. 8080 for the
  # linkers demo (systemd user service on this box).
  denis.firewall.enable = false;

  # ── Kernel / routing ──────────────────────────────────
  denis.latestKernel = true;
  denis.ipForward = true;

  # ── Feature toggles ───────────────────────────────────
  denis.docker.enable = true;
  denis.gaming.enable = true;
  denis.xray.enable = true;
  denis.happ.enable = true;
  denis.wakeOnLan.enable = true;
  denis.tmux.enable = true;

  # ── PC-only user packages ─────────────────────────────
  denis.userPackages = with pkgs; [
    libreoffice
    gnomeExtensions.control-monitor-brightness-and-volume-with-ddcutil
  ];

  # ── NVIDIA (RTX 5070 / Blackwell, open kernel module) ─
  hardware.nvidia = {
    open = true;
    powerManagement.enable = true; # needed for proper suspend/resume
  };
  services.xserver.videoDrivers = [ "nvidia" ];

  # ── Jellyfin media (256GB loopback mount) ──────────────
  fileSystems."/home/denis/jellyfin/media" = {
    device = "/home/denis/jellyfin/media.img";
    fsType = "ext4";
    options = [
      "loop"
      "noatime"
    ];
  };
}
