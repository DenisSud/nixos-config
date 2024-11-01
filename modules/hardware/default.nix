{ config, lib, pkgs, ... }:

{
  imports = [
    ./nvidia.nix
    ./audio.nix
    ./bluetooth.nix
  ];

  # Common hardware configuration
  hardware = {
    enableRedistributableFirmware = true;
    enableAllFirmware = true;

    # OpenGL configuration
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };
  };

  # CPU microcode updates
  hardware.cpu.amd.updateMicrocode = true;

  # USB support
  services.udev.packages = with pkgs; [
    gnome.gnome-settings-daemon
  ];
}
