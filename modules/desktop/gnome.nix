{ config, lib, pkgs, ... }:

{
  # Enable the GNOME Desktop Environment
  services.xserver = {
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  # GNOME Settings
  services.gnome = {
    core-utilities.enable = true;
    gnome-keyring.enable = true;
    gnome-online-accounts.enable = true;
    tracker.enable = true;
    tracker-miners.enable = true;
  };

  # Install GNOME extensions
  environment.systemPackages = with pkgs; [
    gnomeExtensions.caffeine
    gnomeExtensions.vitals
    gnomeExtensions.dash-to-dock
    gnome.gnome-tweaks
  ];

  # Remove unwanted GNOME packages
  environment.gnome.excludePackages = with pkgs.gnome; [
    geary # email reader
    totem # video player
    epiphany # web browser
    gedit # text editor
    pkgs.gnome-text-editor
    pkgs.gnome-photos
    pkgs.gnome-tour
    gnome-characters
    gnome-contacts
    gnome-logs
    yelp # help
    pkgs.gnome-connections
    simple-scan
    gnome-maps
    cheese # webcam tool
    seahorse # password manager
    tali # poker game
    iagno # go game
    hitori # sudoku game
    atomix # puzzle game
    gnome-terminal
  ];

  # Configure GNOME dconf settings
  dconf.settings = {
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
        "caffeine@patapon.info"
        "Vitals@CoreCoding.com"
        "dash-to-dock@micxgx.gmail.com"
      ];
    };

    "org/gnome/desktop/interface" = {
      enable-hot-corners = true;
      show-battery-percentage = true;
    };

    "org/gnome/desktop/wm/preferences" = {
      button-layout = "appmenu:minimize,maximize,close";
    };
  };
}
