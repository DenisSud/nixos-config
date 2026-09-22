{
  pkgs,
  ...
}:

{
  # ╔══════════════════════════════════════════════════════════╗
  # ║  PC — Desktop (AMD Ryzen + NVIDIA RTX 5070 / Blackwell)  ║
  # ╚══════════════════════════════════════════════════════════╝
  # Imports every common module, then layers on PC-only extras
  # (Docker, gaming stack, Xray proxy).

  imports = [
    # ── Common modules ──────────────────────────────────
    ../modules/boot.nix
    ../modules/nix.nix
    ../modules/network.nix
    ../modules/locale.nix
    ../modules/graphics.nix
    ../modules/audio.nix
    ../modules/desktop.nix
    ../modules/fonts.nix
    ../modules/services.nix
    ../modules/dev-tools.nix
    ../modules/shell-utils.nix
    ../modules/web-search.nix
    ../modules/user.nix
    ../modules/programs.nix
    ../modules/vial.nix

    # ── PC-only modules ─────────────────────────────────
    ../modules/virtualization.nix
    ../modules/gaming.nix
    ../modules/xray.nix
    ../modules/ollama.nix
    ../modules/wake-on-lan.nix
    ../modules/tmux.nix
  ];

  # ── Host identity ─────────────────────────────────────
  networking.hostName = "pc";

  # ── Firewall: kept off on pc ─────────────────────────
  # Flipped off 2026-08-31 ("temporarily disabled") and never reverted.
  # Turning it on needs the LAN ports opened first, e.g. 8080 for the
  # linkers demo (systemd user service on this box).
  networking.firewall.enable = false;

  # ── Wake-on-LAN (magic packet) ────────────────────────
  # NetworkManager applies this on every eno1 activation,
  # so WOL survives reconnects and suspend/resume cycles.
  # Wake remotely via the always-on RPi:
  #   ssh pi.wan 'wakeonlan 60:cf:84:dc:80:22'
  networking.networkmanager.connectionConfig."ethernet.wake-on-lan" = "magic";

  # ── Jellyfin media (256GB loopback mount) ──────────────
  fileSystems."/home/denis/jellyfin/media" = {
    device = "/home/denis/jellyfin/media.img";
    fsType = "ext4";
    options = [ "loop" "noatime" ];
  };

  # ── State version ─────────────────────────────────────
  system.stateVersion = "25.05";
  nixpkgs.config.allowUnfree = true;

  # ── Kernel ────────────────────────────────────────────
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  # ── NVIDIA (RTX 5070 / Blackwell, open kernel module) ─
  hardware.nvidia = {
    open = true;
    powerManagement.enable = true; # needed for proper suspend/resume
  };
  services.xserver.videoDrivers = [ "nvidia" ];

  # ── PC-only user packages ─────────────────────────────
  users.users.denis.packages = with pkgs; [
    libreoffice
    gnomeExtensions.control-monitor-brightness-and-volume-with-ddcutil
  ];
}
