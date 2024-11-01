{ config, lib, pkgs, ... }:

{
  imports = [
    ./gnome.nix
    ./fonts.nix
    ./gtk.nix
  ];

  # Enable X11 windowing system
  services.xserver = {
    enable = true;

    # Configure keymap
    layout = "us";
    xkbVariant = "";

    # Enable touchpad support
    libinput = {
      enable = true;
      touchpad = {
        tapping = true;
        naturalScrolling = true;
        middleEmulation = true;
        disableWhileTyping = true;
      };
    };
  };

  # Enable XDG Portal
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
    ];
  };

  # Enable common desktop packages
  environment.systemPackages = with pkgs; [
    # Screenshots
    grim
    slurp

    # Clipboard
    wl-clipboard
    cliphist

    # File management
    gnome.nautilus
    gnome.file-roller

    # System monitors
    gnome.gnome-system-monitor

    # Authentication
    gnome.gnome-keyring

    # Color picker
    gpick
  ];

  # Enable DBus
  services.dbus.enable = true;

  # Enable sound
  sound.enable = true;
}
