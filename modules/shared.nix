# ── Shared layer (pc + g14) ───────────────────────────────────────────
# Imports every common module and the optional feature modules (each of
# which declares its own `denis.<feature>.enable` toggle), and declares
# the `denis.*` options that vary between hosts.
#
# Host files in ../hosts/ import this module and set option values only;
# the host-specific hardware config (NVIDIA/Prime, file systems) stays in
# the host file where it belongs.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.denis;
in
{
  imports = [
    # ── Common modules (both hosts) ─────────────────────
    ./boot.nix
    ./nix.nix
    ./network.nix
    ./locale.nix
    ./graphics.nix
    ./audio.nix
    ./desktop.nix
    ./fonts.nix
    ./services.nix
    ./dev-tools.nix
    ./shell-utils.nix
    ./web-search.nix
    ./user.nix
    ./programs.nix
    ./vial.nix

    # ── Optional stacks (feature toggles, off by default) ─
    ./virtualization.nix # denis.docker.enable
    ./gaming.nix # denis.gaming.enable
    ./xray.nix # denis.xray.enable
    ./wake-on-lan.nix # denis.wakeOnLan.enable
    ./tmux.nix # denis.tmux.enable
    ./asus.nix # denis.asus.enable
  ];

  options.denis = {
    hostName = lib.mkOption {
      type = lib.types.str;
      example = "pc";
      description = "Networking hostname for this machine.";
    };

    firewall.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Whether to enable the NixOS firewall. Inbound ports are opened per
        service via networking.firewall.allowed*.
      '';
    };

    latestKernel = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Use pkgs.linuxPackages_latest instead of the default kernel.";
    };

    ipForward = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable net.ipv4.ip_forward (IPv4 routing / Docker NAT).";
    };

    userPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Host-specific packages added to the denis user profile.";
    };
  };

  config = {
    networking.hostName = cfg.hostName;
    networking.firewall.enable = cfg.firewall.enable;

    system.stateVersion = "25.05";
    nixpkgs.config.allowUnfree = true;

    boot.kernelPackages = lib.mkIf cfg.latestKernel pkgs.linuxPackages_latest;
    boot.kernel.sysctl."net.ipv4.ip_forward" = lib.mkIf cfg.ipForward 1;

    users.users.denis.packages = cfg.userPackages;
  };
}
