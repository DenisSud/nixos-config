# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    # kernelModules = [ "i2c-dev" "ddcci-backlight" ]; 
    kernelModules = [ "i2c-dev" "ddcci_backlight" ]; 
    kernelPackages = pkgs.linuxPackages_latest;
    extraModulePackages = [ config.boot.kernelPackages.ddcci-driver ];

    initrd.luks.devices."luks-78895b41-a0c1-41fb-9762-370ec76458a4".device = "/dev/disk/by-uuid/78895b41-a0c1-41fb-9762-370ec76458a4";
  };

  networking = {
    hostName = "g14";
    networkmanager.enable = true;
    firewall.enable = false;
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  time.timeZone = "Europe/Moscow";

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
    twingate.enable = true;
    open-webui = {
      enable = true;
      port = 1001;
    };
    ollama = {
      enable = true;
      acceleration = "cuda";
      loadModels = [ "qwen3:4b" "qwen3:30b"];
    };
    xserver = {
      videoDrivers = ["nvidia" "amdgpu"];
      enable = true;

      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;

      xkb = {
        layout = "us";
        variant = "";
      };
    };

    printing.enable = true;

    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    openssh.enable = true;
  };

  hardware = {
    i2c.enable = true;
    bluetooth.enable = true;
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    nvidia-container-toolkit.enable = true;
    nvidia = {
      modesetting.enable = true;
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
        amdgpuBusId = "PCI:4:0:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };
  };

  virtualisation.docker = {
    enable = true;
  };

  security.rtkit.enable = true;

  users.users.denis = {
    isNormalUser = true;
    description = "Denis";
    extraGroups = [ "networkmanager" "wheel" "docker" "i2c" ];
    packages = with pkgs; [
      rip2
      gemini-cli
      unzip
      fzf
      ripgrep
      starship
      obsidian
      vscode
      ghostty
      fragments
      telegram-desktop
      lutris
      mangohud
      xclip
      bash-completion
      starship
      zoxide
      libreoffice
      alpaca
      jellyfin-media-player
      gnomeExtensions.brightness-control-using-ddcutil
      gnomeExtensions.caffeine
      gnomeExtensions.clipboard-indicator
      gnomeExtensions.blur-my-shell
    ];
  };

  # Install firefox.
  programs = {
    firefox.enable = true;

    steam = {
      enable = true;
      gamescopeSession.enable = true;
    };

    nh = {
      enable = true;
      flake = "/home/denis/NixOS-Config";
      clean = {
        enable = true;
        dates = "weekly"; # Automatically clean old generations weekly
      };
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  # Enable cuda for all supporting packages
  nixpkgs.config.cudaSuppor = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # System essentials
    ffmpeg # Media file conversion utility
    btop # Hardware info in the cli
    git # Version control system
    gcc # GNU Compiler Collection
    pkg-config # Helps in determining compiler and linker flags for libraries
    wget curl # Command-line tools for transferring data from networks
    tmux # Terminal multiplexer
    file # Utility for determining file types
    dig # DNS troubleshooting tools
    iw # Tool for configuring wireless networks
    tree # Displays directory structures visually
    neovim # Command-line text editor
    jq # Command-line JSON processor
    ddcutil # for gnome to properly detect external monitors
  ];

  system.stateVersion = "25.05";
}
