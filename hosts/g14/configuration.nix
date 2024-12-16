{ lib, config, pkgs, inputs, ... }:

{
  imports =
    [
    ./hardware-configuration.nix
      ../../modules/wireguard
    ];

  boot = {
    loader = {
      grub = {
        efiSupport = true;
        efiInstallAsRemovable = true;
        device = "nodev";
      };
    };
  };
  xdg = {
    portal.enable = true;
    mime.enable = true;
    menus.enable = true;
  };

  virtualisation = {
    docker = {
      enable = true;
      enableNvidia = true;
    };
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
    excludePackages = [ pkgs.xterm ];
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  networking = {
    hostName = "g14";
    networkmanager.enable = true;
    firewall = {
      enable = false;
      allowedTCPPorts = [ 8384 22000 ];
      allowedUDPPorts = [ 22000 21027 51820 80 443 67 68];
    };
    vpn = {
      nl-mlv.enable = false;
      us.enable = false;
    };
  };

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

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  programs = {
    gnupg.agent = {
      enable = true;
      pinentryPackage = pkgs.pinentry-curses;
    };
    git = {
      enable = true;
      lfs.enable = true;
    };
    nh = {
      enable = true;
      clean.enable = true;
      flake = "/home/denis/NixOS";
    };
    direnv.enable = true;
  };

  services = {
    pcscd.enable = true;
    syncthing = {
      enable = true;
      user = "denis";
      dataDir = "/home/denis/Sync";
    };
    flatpak.enable = true;
    resolved = {
      enable = true;
    };
    openssh = {
      enable = lib.mkDefault true;
    };
    ollama = {
      enable = true;
      acceleration = "cuda";
    };
  };

  nixpkgs.config = {
      allowUnfree = true;
  };

  environment = {
    systemPackages = with pkgs; [
      impression
      gnome-tweaks
      neovim
      neofetch
      onefetch
      gcc
      curl
      wget
      bat
      git
      git-lfs
      nvtopPackages.full
      htop
      dust
      gnomeExtensions.pip-on-top
      gnomeExtensions.caffeine # no sleep
      gnomeExtensions.clipboard-indicator
      gnomeExtensions.blur-my-shell
      gnomeExtensions.vitals # system resources
    ];

    gnome.excludePackages = (with pkgs; [
      totem
      gnome-photos
      gnome-tour
      gnome-text-editor
      gnome-connections
      simple-scan
      gnome-usage
      gnome-system-monitor
      cheese
      seahorse
      eog
      yelp
      epiphany
      gnome-logs
      gnome-maps
      gnome-contacts
      gnome-music
      gnome-characters
      gnome-weather
      gnome-clocks
      tali
      iagno
      hitori
      atomix
      gnome-console
      gnome-keyring
      gnome-terminal
    ]);
  };
# Hardware-specific settings
  powerManagement.cpuFreqGovernor = "powersave";
  hardware = {
    bluetooth.enable = true;
    pulseaudio.enable = false;

    graphics = {
      enable = true;
      enable32Bit = true;
    };

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
        amdgpuBusId = "PCI:4:0:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };
  };

# User configuration
  stylix = {
    enable = true;
    image = lib.mkDefault ../../modules/wallpapers/FantasyWoods.jpg;
    polarity = lib.mkDefault "dark";
    base16Scheme = lib.mkDefault "${pkgs.base16-schemes}/share/themes/black-metal.yaml";
  };

  specialisation.light.configuration = {
    environment.etc."specialisation".text = "light"; # this is for 'nh' to correctly recognise the specialisation
    stylix = {
      enable = true;
      image = ../../modules/wallpapers/Architecture.jpg;
      polarity = "light";
      base16Scheme = "${pkgs.base16-schemes}/share/themes/rose-pine-dawn.yaml";
    };
  };

  users.users.denis = {
    isNormalUser = true;
    shell = pkgs.nushell;
    description = "denis";
    initialPassword = "password";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [
      # Base packages
      eyedropper
      alpaca
      libreoffice-qt
      telegram-desktop
      yandex-music
      obs-studio
      obsidian
      gimp

      # Dev packages
      docker-compose
      zed-editor
      kitty
      pipenv

      # Shell packages
      speedtest-rs
      starship
      ripgrep
      nushell
      zellij
      zoxide
      oxker
      tree
      ddgr
      dust
      fzf
      eza
      bat
      jq

      # Virtualization
      bottles
      virtualbox
    ];
  };

  home-manager = {
    extraSpecialArgs = {inherit inputs;};
    backupFileExtension = "backup";
    users = {
      "denis" = import ./home.nix;
    };
  };

  system.stateVersion = "24.05"; # Did you read the comment?

}
