{ config, pkgs, ... }:

{

  programs = {
    zsh.enable = true;
    hyprland = {
      enable = true;
    };
  };

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./modules/hardware.nix
      ./modules/rice.nix
      ./modules/services.nix
      ./modules/users.nix
      <home-manager/nixos>
      <nixos-hardware/asus/zephyrus/ga401>
    ];

  nix = {
    optimise.automatic = true;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  home-manager = {
    users = {
      "denis" = import ./home.nix; 
    };
  };

  # Set your time zone.
  time.timeZone = "Europe/Moscow";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ru_RU.UTF-8";
    LC_IDENTIFICATION = "ru_RU.UTF-8";
    LC_MEASUREMENT = "ru_RU.UTF-8";
    LC_MONETARY = "ru_RU.UTF-8";
    LC_NAME = "ru_RU.UTF-8";
    LC_NUMERIC = "ru_RU.UTF-8";
    LC_PAPER = "ru_RU.UTF-8";
    LC_TELEPHONE = "ru_RU.UTF-8";
    LC_TIME = "ru_RU.UTF-8";
  };


  # Use the systemd-boot EFI boot loader.
  # security.polkit.enable = true;

  boot = {
    loader.systemd-boot.configurationLimit = 10;
    blacklistedKernelModules = [ "nouveau" "nvidiafb" ];
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  networking = {
    hostName = "g14-nixos";
  };
  
  environment = { 
    systemPackages = with pkgs; [
      gnomeExtensions.vitals
      libappimage
      curl
      firefox
      fzf
      git
      xclip
      btop
      nvtopPackages.full
      neofetch
    ];

    gnome.excludePackages = (with pkgs; [
      gnome-text-editor
      gnome-console
      gnome-photos
      gnome-tour
      gnome-connections
      simple-scan
      gnome-usage
    ]) ++
    (with pkgs.gnome; [
      gnome-calculator
      gnome-system-monitor
      cheese
      gnome-logs
      seahorse
      eog
      gnome-maps
      gnome-font-viewer
      yelp
      gnome-calendar
      gnome-contacts
      gnome-music
      gnome-software
      epiphany # web browser
      geary # email reader
      evince # document viewer
      gnome-characters
      gnome-weather
      gnome-clocks
      totem # video player
      tali # poker game
      iagno # go game
      hitori # sudoku game
      atomix # puzzle game
    ]);
  };  

  # Enable sound.
  sound.enable = true;


  nixpkgs = {

    config.allowUnfree = true;
  
    config.permittedInsecurePackages = [
      "electron-25.9.0"
    ];

  };

  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?

}
