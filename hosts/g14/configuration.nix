{ config, lib, pkgs, inputs, ... }: {
    imports = [
        ./hardware-configuration.nix
    ];

# System configuration
    networking = {
        hostName = "g14";
        networkmanager.enable = true;
        firewall.enable = false;
    };

# Basic system settings
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    time.timeZone = "Europe/Moscow";
    nixpkgs.config.allowUnfree = true;

# Localization
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

# Boot configuration
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

# Hardware configuration
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

    virtualisation = {
        containers.enable = true;
        oci-containers.backend = "podman";
        podman = {
            enable = true;
            dockerCompat = true;
            defaultNetwork.settings.dns_enabled = true;
        };
    };

    stylix = {
        enable = true;
        image = lib.mkDefault ../../wallpapers/Mountain.png;
        polarity = lib.mkDefault "dark";
        base16Scheme = lib.mkDefault "${pkgs.base16-schemes}/share/themes/vesper.yaml";
    };

# System services
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
                OLLAMA_HOST = "0.0.0.0:11434";  # Allow external access
            };
        };
        open-webui = {
            enable = true;
            port = 2025;
        };
        twingate.enable = true;
        flatpak.enable = true;
        printing.enable = true;
        openssh.enable = true;
    };

# Basic system programs
    programs = {
        git.enable = true;
        nh = {
            enable = true;
            clean = {
                enable = true;
                dates = "weekly";  # optional: automatically clean old generations
            };
        };
    };

# Essential system packages
    environment.systemPackages = with pkgs; [
# System essentials
        libfprint
        neovim
        curl
        wget
        git
        fzf

# Gnome specific
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

# User configuration
    users.users.denis = {
        isNormalUser = true;
        shell = pkgs.nushell;
        description = "denis";
        initialPassword = "password";
        extraGroups = [ "networkmanager" "wheel" "docker" ];
        packages = with pkgs; [
            tor-browser
            zed-editor
            code-cursor
            galaxy-buds-client
            telegram-desktop
            gnome-solanum
            eyedropper
            seahorse
            obsidian
            twingate
            bottles
            alpaca
       ];
    };

# Home Manager configuration
    home-manager = {
        extraSpecialArgs = {inherit inputs;};
        backupFileExtension = "back";
        users.denis = import ./home.nix;
    };

    system.stateVersion = "24.05";
                                    }
