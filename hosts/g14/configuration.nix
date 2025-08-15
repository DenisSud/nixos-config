{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  # System & Basic Settings for
  #########################################################

  # Networking & Hostname
  networking = {
    hostName = "g14";
    networkmanager.enable = true;
    firewall.enable = false;
  };

  # Core System Settings
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  time.timeZone = "Europe/Moscow";
  nixpkgs.config = {
    allowUnfree = true;
    enableCuda = true;
  };

  # Localization Settings
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
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
  };

  fonts = {
    packages = with pkgs; [
      noto-fonts # Universal sans-serif fonts for many languages
      noto-fonts-emoji # Emoji rendering
      liberation_ttf # Popular alternative to Arial, Times New Roman, etc.
      ubuntu_font_family # Clean and widely used sans-serif font
      cantarell-fonts # Commonly used in GNOME environments
      font-awesome # Icon font for i3status
      nerd-fonts.jetbrains-mono # Programming fonts with iconsnerd
    ];
  };

  # Boot & Hardware Configuration
  #########################################################

  # Boot Loader & GRUB

  security.polkit.enable = true;
  boot = {
    extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
    kernelModules = [ "v4l2loopback" ];
    extraModprobeConfig = ''
      options v4l2loopback video_nr=2 width=1920 max_width=1920 height=1080 max_height=1080 format=YU12 exclusive_caps=1 card_label=GoPro debug=1
    '';
    loader = {
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
  };

  # Hardware Settings
  hardware = {
    bluetooth.enable = true;
    graphics = {
      enable = true;
    };
    nvidia-container-toolkit.enable = false;
    nvidia = {
      modesetting.enable = true;
      open = true;
      powerManagement = {
        enable = false;
        finegrained = false;
      };
      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
        amdgpuBusId = "PCI:4:0:0";
        nvidiaBusId = "PCI:1:0:0";
      };
      # package = config.boot.kernelPackages.nvidiaPackages.stable;
      # prime = {
      # };
    };
  };

  # Virtualisation & Visual Customization
  #########################################################

  # Virtualisation Settings
  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
    docker.enable = false;
  };

  # Services Configuration
  #########################################################

  services = {
    udev.extraHwdb = ''
      evdev:name:*:dmi:bvn*:bvr*:bd*:svnASUS*:pn*:*
      KEYBOARD_KEY_ff31007c=f20    # fixes mic mute button
      KEYBOARD_KEY_ff3100b2=home   # Set fn+LeftArrow as Home
      KEYBOARD_KEY_ff3100b3=end    # Set fn+RightArrow as End
    '';

    xserver.enable = true;
    xserver.videoDrivers = ["nvidia"];
    xserver.displayManager.gdm.enable = true;
    xserver.desktopManager.gnome.enable = true;
    #
    # displayManager.gdm.enable = true;
    # desktopManager.gnome.enable = true;

    ollama = {
      enable = true;
      acceleration = "cuda";
    };

    twingate.enable = false;
    flatpak.enable = true;
    printing.enable = true;
    openssh.enable = true;
  };

  # Basic Programs & Essential System Packages
  #########################################################

  # Basic system programs configuration
  programs = {
    git.enable = true;
    adb.enable = true;
    zsh.enable = true;
    thunar.enable = true;
    nh = {
      enable = true;
      flake = "/home/denis/NixOS";
      clean = {
        enable = true;
        dates = "weekly"; # Automatically clean old generations weekly
      };
    };
    ssh = {
      extraConfig = ''
        Host *
        SetEnv TERM=xterm-256color
      '';
    };
  };

  # System-wide packages to be installed
  environment = {
    systemPackages = with pkgs; [
      helix
      neovim
      ffmpeg
      vlc
      curl
      wget
      git
      fzf
      ghostty
      rquickshare
      gnomeExtensions.gsconnect
      gnomeExtensions.wintile-beyond
      gnomeExtensions.caffeine
      gnomeExtensions.clipboard-indicator
      gnomeExtensions.blur-my-shell
      gnomeExtensions.vitals
      gnomeExtensions.zen
    ];
  };

  # Stylix
  #########################################################

  stylix = {
    enable = true;
    image = ../../wallpapers/School_of_Athens.jpg;
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/kanagawa-dragon.yaml";
  };

  # User & Home Manager Configuration
  #########################################################

  # User configuration for 'denis'
  users.users.denis = {
    isNormalUser = true;
    shell = pkgs.zsh;
    description = "denis";
    initialPassword = "password";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
    packages = with pkgs; [
      gcc
      cudaPackages.cudatoolkit
      cudaPackages.cudnn
      lima
      tor
      android-tools # For ADB
      qbittorrent
      foliate # eBook reader
      chromium
      obs-studio
      v4l-utils # Camera utilities
      droidcam # Client application
      zed-editor # code editor
      vscode # the devil
      telegram-desktop # messenger
      libreoffice # office suite
      obsidian # note taking and knowledge base
      bottles
      twingate # remote management
      jellyfin-media-player
            # Development tools
      btop
      qwen-code
      gemini-cli
      podman-compose
      zellij
      starship
      fabric-ai
      ripgrep
      lazygit
      lazysql
      lazydocker 
      git-lfs # Large file storage for git
      zoxide # Better cd
      harper # Grammer language server
      rip2 # Better rm
      bat # Better cat
      jq # Json quiry
      gh # GitHub cli tool
      xh # HTTP requests
      mprocs

# Shell utilities
      unzip
      zip
      cargo
      xclip
      carapace
      zsh
      dust
      pandoc
      nmap
      tree
      gnutar

# For language servers
      nodejs
      python3
      pyright
      gopls
      nil

      # zsh-syntax-highlighting
      zsh-syntax-highlighting

    ];
  };

  # Home Manager configuration for 'denis'
  home-manager = {
    backupFileExtension = "backup";
    users.denis = import ./home.nix;
  };

  # System State Version
  #########################################################

  system.stateVersion = "25.05";

}
