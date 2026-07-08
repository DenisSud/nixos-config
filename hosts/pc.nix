{
  pkgs,
  ...
}:

{
  # ╔══════════════════════════════════════════════════════════╗
  # ║  PC — Desktop (AMD Ryzen + NVIDIA RTX 5070 / Blackwell)  ║
  # ╚══════════════════════════════════════════════════════════╝
  # Imports every common module, then layers on PC-only extras
  # (Docker, Ollama+CUDA on LAN, gaming stack, Xray proxy).

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
    ../modules/user.nix
    ../modules/programs.nix

    # ── PC-only modules ─────────────────────────────────
    ../modules/virtualization.nix
    ../modules/ollama.nix
    ../modules/gaming.nix
    ../modules/xray.nix
  ];

  # ── Host identity ─────────────────────────────────────
  networking.hostName = "pc";

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
