{ config, lib, pkgs, inputs, ... }:

{

  #########################################################
  # Imports
  #########################################################
  imports = [
    ./hardware-configuration.nix
  ];

  #########################################################
  # System & Basic Settings
  #########################################################

  # Networking & Hostname
  networking = {
    hostName = "g14";
    networkmanager.enable = true;
    firewall.enable = false;
  };

  # Core System Settings
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  time.timeZone = "Europe/Moscow";
  nixpkgs.config.allowUnfree = true;

  # Localization Settings
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS         = "ru_RU.UTF-8";
      LC_IDENTIFICATION  = "ru_RU.UTF-8";
      LC_MEASUREMENT     = "ru_RU.UTF-8";
      LC_MONETARY        = "ru_RU.UTF-8";
      LC_NAME            = "ru_RU.UTF-8";
      LC_NUMERIC         = "ru_RU.UTF-8";
      LC_PAPER           = "ru_RU.UTF-8";
      LC_TELEPHONE       = "ru_RU.UTF-8";
      LC_TIME            = "ru_RU.UTF-8";
    };
  };

  #########################################################
  # Boot & Hardware Configuration
  #########################################################

  # Boot Loader & GRUB
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
    grub = {
      enable = true;
      devices = [ "nodev" ];
      efiSupport = true;
      useOSProber = true;
    };
  };

  # Hardware Settings
  hardware = {
    bluetooth.enable = true;
    graphics.enable = true;
    nvidia-container-toolkit.enable = true;
    nvidia = {
      modesetting.enable = true;
      package = config.boot.kernelPackages.nvidiaPackages.production;
      open = false;
      powerManagement = {
        enable = true;
        finegrained = true;
      };
      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
      };
    };
  };

  #########################################################
  # Virtualisation & Visual Customization
  #########################################################

  # Virtualisation Settings
  virtualisation = {
    containers.enable = true;
    oci-containers.backend = "podman";
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  # Stylix (Theme/Image) Settings
  stylix = {
    enable = true;
    image = lib.mkDefault ../../wallpapers/touch.png;
    polarity = lib.mkDefault "dark";
    base16Scheme = lib.mkDefault "${pkgs.base16-schemes}/share/themes/mountain.yaml";
  };

  #########################################################
  # Services Configuration
  #########################################################

  services = {
    xserver = {
      enable = true;
      excludePackages = [ pkgs.xterm ];
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };

    ollama = {
      enable = true;
      acceleration = "cuda";
      environmentVariables = {
        OLLAMA_HOST = "0.0.0.0:11434"; 
      };
    };

    twingate.enable = true;
    flatpak.enable = true;
    printing.enable = true;
    openssh.enable = true;
    # gnome.core-utilities.enable = false;
  };

  #########################################################
  # Basic Programs & Essential System Packages
  #########################################################

  # Basic system programs configuration
  programs = {
    git.enable = true;
    nh = {
      enable = true;
      clean = {
        enable = true;
        dates = "weekly";  # Automatically clean old generations weekly
      };
    };
  };

  # System-wide packages to be installed
  environment.systemPackages = with pkgs; [
    libfprint
    neovim
    curl
    wget
    git
    fzf
    ghostty
    gnome-tweaks
    gnomeExtensions.twingate-status
    gnomeExtensions.wintile-beyond
    gnomeExtensions.pip-on-top
    gnomeExtensions.caffeine
    gnomeExtensions.clipboard-indicator
    gnomeExtensions.blur-my-shell
    gnomeExtensions.vitals
  ];

  #########################################################
  # User & Home Manager Configuration
  #########################################################

  # User configuration for 'denis'
  users.users.denis = {
    isNormalUser = true;
    shell = pkgs.nushell;
    description = "denis";
    initialPassword = "password";
    extraGroups = [ "networkmanager" "wheel" "podman" "docker" ];
    packages = with pkgs; [
      ticktick # taks management
      tor-browser # anonymous browser
      zed-editor # code editor
      galaxy-buds-client # utility for galaxy buds
      telegram-desktop # messenger
      gnome-solanum # pomo timer
      libreoffice # office suite
      eyedropper # color picker
      seahorse # password manager
      obsidian # note taking and knowledge base
      twingate # remote management
      bottles # wine bottles manager
      alpaca # for local chats
      zotero # For managin research papers
    ];
  };

  # Home Manager configuration for 'denis'
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    backupFileExtension = "back";
    users.denis = import ./home.nix;
  };

  #########################################################
  # System State Version
  #########################################################

  system.stateVersion = "24.05";

}

