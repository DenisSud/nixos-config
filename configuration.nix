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

    zsh.enable = true;

    git = {
      enable = true;
      lfs.enable = true;
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

  stylix = {
    enable = true;
    image = ./wallpaper/dune.jpg;
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/atelier-dune.yaml";
    fonts = {
      serif = {
        package = pkgs.nerdfonts;
        name = "JetBrainsMono Nerd Font";
      };
      sansSerif = {
        package = pkgs.nerdfonts;
        name = "JetBrainsMono Nerd Font";
      };
      monospace = {
        package = pkgs.nerdfonts;
        name = "JetBrainsMono Nerd Font";
      };
    };
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ]; 

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.firewall.enable  = true;

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

    flatpak = {
      enable = true;
    };

    fprintd = {
      enable = true;
      package = pkgs.fprintd-tod;
      tod.enable = true;
      tod.driver = pkgs.libfprint-2-tod1-goodix;
    };

    printing = {
      enable = true;
      browsing = true;
      defaultShared = true;
      listenAddresses = [ "*:631" ];
      allowFrom = [ "all" ];
      drivers = with pkgs; [
        gutenprint
        cups-filters
        hplipWithPlugin
      ];
    };

    asusd = {
      enable = true;
      enableUserService = true;
    };

    dnsmasq.enable = true;

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

    graphics.enable = true;
    
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
    password = "asdfghjkl;'";
    extraGroups = [ "wheel" "networkmanager" "docker" ];
    packages = with pkgs; [
      # Apps
      wine
      gimp
      neovim
      flatpak
      ticktick
      obsidian
      newsflash
      zed-editor
      impression
      gnome-graphs
      wireguard-tools
      telegram-desktop
      gnome-software

      # Shell stuff
      go
      git
      gcc
      fzf
      bat
      tree
      nodejs
      zoxide
      yt-dlp
      pandoc
      docker
      lazygit
      ripgrep
      git-lfs
      nerdfonts
      fabric-ai
      lazydocker
      home-manager
      texliveMedium
      docker-compose
      vimPlugins.packer-nvim
    ];
    shell = pkgs.bash;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment = {

    variables = {
        NIX_BUILD_SHELL = "zsh";
        EDITOR = "zed";
        DEFAULT_VENDOR = "Groq";
        DEFAULT_MODEL = "llama-3.1-70b-versatile";
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
      # geary # email reader
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
