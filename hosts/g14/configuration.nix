{ config, lib, pkgs, inputs, ... }:
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
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  time.timeZone = "Europe/Moscow";
  nixpkgs.config = {
    allowUnfree = true;
    enableCuda = true;
    allowBroken = true;
  };

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

  fonts = {
    packages = with pkgs; [
      noto-fonts                # Universal sans-serif fonts for many languages
        noto-fonts-emoji          # Emoji rendering
        liberation_ttf            # Popular alternative to Arial, Times New Roman, etc.
        ubuntu_font_family        # Clean and widely used sans-serif font
        cantarell-fonts           # Commonly used in GNOME environments
        font-awesome              # Icon font for i3status
        nerd-fonts.jetbrains-mono                 # Programming fonts with icons
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
    graphics.enable = true;
    nvidia-container-toolkit.enable = true;
    nvidia = {
      modesetting.enable = true;
      package = config.boot.kernelPackages.nvidiaPackages.production;
      open = false;
      powerManagement = {
        enable = true;
        finegrained = false;
      };
      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
      };
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
  };

# Services Configuration
#########################################################

  services = {

    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;

    ollama = {
      enable = true;
      acceleration = "cuda";
    };

    twingate.enable = true;
    # flatpak.enable = true;
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
        dates = "weekly";  # Automatically clean old generations weekly
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
        gnomeExtensions.penguin-ai-chatbot
        gnomeExtensions.wintile-beyond
        gnomeExtensions.pip-on-top
        gnomeExtensions.caffeine
        gnomeExtensions.clipboard-indicator
        gnomeExtensions.blur-my-shell
        gnomeExtensions.vitals
        # i3 packages - available system-wide
        i3status
        i3lock
        rofi
        picom
        feh
        brightnessctl
        playerctl
        pulseaudio
        pavucontrol
        arandr
        nitrogen
        dunst
    ];
  };


# Specializations
#########################################################

  specialisation = {
    i3.configuration = {
      # Disable GNOME for i3 specialization
      services.desktopManager.gnome.enable = lib.mkForce false;
      services.displayManager.gdm.enable = lib.mkForce false;
      
      # Enable i3 and related services
      services.xserver = {
        enable = true;
        displayManager = {
          lightdm.enable = true;
          defaultSession = "none+i3";
        };
        windowManager.i3 = {
          enable = true;
          extraPackages = with pkgs; [
            dmenu
            i3status
            i3lock
            i3blocks
          ];
        };
      };
      
      # Enable compositor for transparency and effects
      services.picom = {
        enable = true;
        fade = true;
        shadow = true;
        fadeDelta = 4;
      };
      
      # Notification daemon
      # services.dunst.enable = true;
      
      # Sound settings for i3
      # sound.enable = true;
      # hardware.pulseaudio.enable = true;
      
      # Additional packages for i3 environment
      environment.systemPackages = with pkgs; [
        # Application launcher
        rofi
        dmenu
        
        # Status bar
        i3status
        i3blocks
        
        # System utilities
        networkmanagerapplet
        blueman
        
        # File manager
        # thunar uses programs.thunar.enable
        
        # Screenshot tools
        scrot
        maim
        
        # System monitor
        htop
        
        # Terminal emulator (if you want an alternative)
        alacritty
        
        # Volume control
        pamixer
        
        # Clipboard manager
        clipmenu
      ];
    };
  };

# Stylix
#########################################################

  stylix = {
    enable = lib.mkDefault true;
    image = lib.mkDefault ../../wallpapers/touch.png;
    polarity = lib.mkDefault "dark";
    base16Scheme = lib.mkDefault "${pkgs.base16-schemes}/share/themes/black-metal-gorgoroth.yaml";
  };

# User & Home Manager Configuration
#########################################################

# User configuration for 'denis'
  users.users.denis = {
    isNormalUser = true;
    shell = pkgs.zsh;
    description = "denis";
    initialPassword = "password";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      cudaPackages.cudatoolkit
      cudaPackages.cudnn
      uutils-coreutils-noprefix # replacing standard core utils with rusty alternatives
      galaxy-buds-client
      anki # For studying
      lima
      tor
      opencode
      android-tools  # For ADB
      foliate # eBook reader
      chromium
      obs-studio
      v4l-utils      # Camera utilities
      droidcam       # Client application
      zed-editor # code editor
      code-cursor
      vscode # the devil
      telegram-desktop # messenger
      whatsapp-for-linux
      libreoffice # office suite
      obsidian # note taking and knowledge base
      newsflash
      zoom-us
      bottles
      twingate # remote management
      gnome-chess # chess gui
      gnuchess # chess engine
      dia # gnome diagram editor
    ];
  };

# Home Manager configuration for 'denis'
  home-manager = {
    backupFileExtension = "backup";
    users.denis = import ./home.nix;
  };

# System State Version
#########################################################

  system.stateVersion = "24.11";

}
