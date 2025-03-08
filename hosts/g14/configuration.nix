{ config, lib, pkgs, inputs, ... }:

{
    imports = [
        ./hardware-configuration.nix
    ];

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
    nixpkgs.config = {
        allowUnfree = true;
        allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
        ];
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

    # Boot & Hardware Configuration
    #########################################################

    # Boot Loader & GRUB

    security.polkit.enable = true;
    boot = {
        extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
        kernelModules = [ "v4l2loopback" ];
        extraModprobeConfig = ''
            options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
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
        docker = {
            enable = true;
            enableNvidia = true;
        };
    };

    # Stylix (Theme/Image) Settings
    stylix = {
        enable = lib.mkDefault true;
        image = lib.mkDefault ../../wallpapers/touch.png;
        polarity = lib.mkDefault "dark";
        base16Scheme = lib.mkDefault "${pkgs.base16-schemes}/share/themes/mountain.yaml";
    };

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
        syncthing.enable = true;
    };

    # Basic Programs & Essential System Packages
    #########################################################

    # Basic system programs configuration
    programs = {
        git.enable = true;
        adb.enable = true;
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
        neovim
        curl
        wget
        git
        fzf
        ghostty
        gnomeExtensions.twingate-status
        gnomeExtensions.wintile-beyond
        gnomeExtensions.pip-on-top
        gnomeExtensions.caffeine
        gnomeExtensions.clipboard-indicator
        gnomeExtensions.blur-my-shell
        gnomeExtensions.vitals
    ];

    # Specializations
    #########################################################

    specialisation = {
        light.configuration = {
            stylix = {
                enable = false;
                image = ../../wallpapers/touch.png;
            };
        };
    };

    # User & Home Manager Configuration
    #########################################################

    # User configuration for 'denis'
    users.users.denis = {
        isNormalUser = true;
        shell = pkgs.nushell;
        description = "denis";
        initialPassword = "password";
        extraGroups = [ "networkmanager" "wheel" "docker" ];
        packages = with pkgs; [
            ticktick # taks management
            android-tools  # For ADB
            chromium
            obs-studio
            v4l-utils      # Camera utilities
            droidcam       # Client application
            tor-browser # anonymous browser
            zed-editor # code editor
            code-cursor
            telegram-desktop # messenger
            libreoffice # office suite
            obsidian # note taking and knowledge base
            twingate # remote management
            bottles # wine bottles manager
        ];
        subUidRanges = [
            { startUid = 100000; count = 65536; }
        ];
        subGidRanges = [
            { startGid = 100000; count = 65536; }
        ];
    };

    # Home Manager configuration for 'denis'
    home-manager = {
        extraSpecialArgs = { inherit inputs; };
        backupFileExtension = "backup";
        users.denis = import ./home.nix;
    };

    # System State Version
    #########################################################

    system.stateVersion = "24.11";

}
