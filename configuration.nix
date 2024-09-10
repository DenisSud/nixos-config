{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./users.nix
      ./services.nix
      ./hardware.nix
    ];

  virtualisation.docker = {
    enable = true;
    enableNvidia = true;
  };

  security.rtkit.enable = true;

  programs = {
    gamemode = {
      enable = true;
    };
    git = {
      enable = true;
      lfs.enable = true;
    };
    zsh = {
      enable = true;
    };
    nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 2d --keep 3";
      flake = "/home/denis/nixos-config";
    };
  };

  home-manager.users.denis = import ./home.nix;
  home-manager.backupFileExtension = "backup";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];


  # Bootloader.
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    kernelParams = [ "mem_sleep_default=deep" ];
  };

  networking.hostName = "g14"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

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

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager = {
    gdm.enable = true;
    # gnome.enable = true;
  };

  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "us";
    xkb.variant = "";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment = {

    variables = {
        NIX_BUILD_SHELL = "zsh";
    };

    systemPackages = with pkgs; [
      cudaPackages.cuda_nvcc
      cudaPackages.cudatoolkit
      gnomeExtensions.vitals
      gnome-tweaks
      supergfxctl
      asusctl
      curl
      fzf
      git
      xclip
      btop
    ];

    gnome.excludePackages = (with pkgs; [
      gnome-text-editor
      gnome-photos
      gnome-tour
      gnome-connections
      simple-scan
      gnome-usage
      gnome-system-monitor
      cheese
      seahorse
      eog
      yelp
      geary # email reader
      epiphany # web browser
      evince # document viewer
      gnome-logs
      gnome-maps
      gnome-contacts
      gnome-music
      gnome-software
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

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
