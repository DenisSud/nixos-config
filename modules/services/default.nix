{ config, lib, pkgs, ... }:

{
  imports = [
    ./docker.nix
    ./ssh.nix
    ./ollama.nix
    ./printing.nix
  ];

  # Common service configurations
  services = {
    # Enable CUPS for printing
    printing.enable = true;

    # Enable periodic SSD TRIM
    fstrim.enable = true;

    # Enable thermald for better temperature management
    thermald.enable = true;

    # Enable system auto-upgrade
    auto-upgrade = {
      enable = true;
      allowReboot = false;
      dates = "04:00";
      randomizedDelaySec = "45min";
    };
  };
}
