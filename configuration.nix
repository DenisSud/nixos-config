# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  virtualisation.docker = {
    enable = true;
  };

  programs = {

    firefox = {
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
      flake = "/home/denis/NixOS";
    };

  };
  
  home-manager.users.denis = import ./home.nix;
  home-manager.backupFileExtension = "backup";

  nix.settings.experimental-features = [ "nix-command" "flakes" ]; 

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

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

  services = {

    asusd = {
      enable = true;
      enableUserService = true;
    };

    dnsmasq.enable = true;

    fprintd = {
      enable = true;
      tod.enable = true;
      tod.driver = pkgs.libfprint-2-tod1-goodix;
    };

    supergfxd.enable = true;

    ollama = {
      enable = true;
      acceleration = "cuda";
    };

    xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
      videoDrivers = [ "nvidia" "mesa" ];
      excludePackages = (with pkgs; [
          xterm
      ]);
    };

    openssh.enable = true;

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

  };

  hardware = {

    bluetooth.enable = true;

    pulseaudio.enable = false;

    cpu.amd.updateMicrocode = true;

    # graphics.enable = true;
    
    nvidia-container-toolkit.enable = true;

    nvidia = {
      open = false;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      modesetting.enable = true;
      package = config.boot.kernelPackages.nvidiaPackages.vulkan_beta;
    };

  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.denis = {
    isNormalUser = true;
    password = "1423";
    extraGroups = [ "wheel" "networkmanager" "docker" ];
    packages = with pkgs; [
      # Apps
      ticktick
      zed-editor
      neovim
      wireguard-tools
      obsidian
      anki
      gimp
      beeper
      bottles

      # Shell stuff
      yt-dlp
      fabric-ai
      jupyter
      texliveMedium
      pandoc
      nerdfonts
      git-lfs
      vimPlugins.packer-nvim
      docker
      lazydocker
      lazygit
      gcc
      fzf
      zoxide
      bat
      ripgrep
      zsh
      tree
      home-manager
      nodejs
      go
      git
    ];
    shell = pkgs.zsh;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment = {

    variables = {
        NIX_BUILD_SHELL = "zsh";
        EDITOR = "zed";
        DEFAULT_VENDOR = "SiliconCloud";
        DEFAULT_MODEL = "Qwen/Qwen1.5-110B-Chat";
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
      # evince # document viewer
      gnome-logs
      gnome-maps
      gnome-contacts
      gnome-music
      gnome-software
      gnome-characters
      # gnome-weather
      # gnome-clocks
      totem # video player
      tali # poker game
      iagno # go game
      hitori # sudoku game
      atomix # puzzle game
    ]);
  };

  system.stateVersion = "24.05"; # Did you read the comment?

}
