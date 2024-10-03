{ config, pkgs, ... }:

{
    imports =
        [ # Include the results of the hardware scan.
            ./hardware-configuration.nix
        ];

    virtualisation.docker = {
        enable = true;
        enableNvidia = true;
    };

    programs = {

        # steam = {
        #     enable = true;
        # };

        firefox = {
            enable = true;
        };

        zsh = { 
            enable = true;
        };

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
        image = ./wallpaper/tower.jpg;
        polarity = "dark";
        base16Scheme = "${pkgs.base16-schemes}/share/themes/kanagawa.yaml";
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

    nix = {
        enable = true;
        settings = {
            experimental-features = [ "nix-command" "flakes" ];
            auto-optimise-store = true;
        };
    };

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

        cpupower-gui.enable = true;

        flatpak = {
            enable = true;
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
            videoDrivers = [ "nvidia" ];
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

        graphics = {
            enable = true;
            enable32Bit= true;
        };

        nvidia = {

            prime = {
                offload.enable = true;
                amdgpuBusId = "PCI:4:0:0";
                nvidiaBusId = "PCI:1:0:0";
            };

            open = false;
            
            powerManagement.enable = true;
            modesetting.enable = true;

            package = config.boot.kernelPackages.nvidiaPackages.vulkan_beta;
        };

    };

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.denis = {
        isNormalUser = true;
        password = "jkl;'";
        extraGroups = [ "wheel" "networkmanager" "docker" ];
        packages = with pkgs; [
            # # Performce / Optimizatoin
            # supergfxctl
            # asusctl
            #
            # # Apps
            # gimp
            # runc
            kitty
            neovim
            flatpak
            # ticktick
            # obsidian
            # impression
            # zed-editor
            # wireguard-tools
            # telegram-desktop
            # cudaPackages.cudatoolkit
            gnome-software
            #
            # # Shell stuff
            # nb
            # go
            git
            gcc
            # nodejs
            # rustup
            zoxide
            # pandoc
            # gnumake
            # docker
            # lazygit
            # lazydocker
            # ripgrep
            # git-lfs
            # fabric-ai
            # home-manager
            # docker-compose
        ];
        shell = pkgs.zsh;
    };

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    environment = {

        variables = {
            EDITOR = "nvim";
            WINEPREFIX = "$HOME/.wine";
            DEFAULT_VENDOR = "Ollama";
            DEFAULT_MODEL = "llama3.2:latest";
            NIXPKGS_ALLOW_UNFREE = 1;
        };

        systemPackages = with pkgs; [
            gnome-tweaks
            ffmpeg
            curl
            fzf
            nb
            git
            bat
            tree
            xclip
            btop
        ];

        gnome.excludePackages = (with pkgs; [
            # geary # email reader
            # evince # document viewer
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
            epiphany # web browser
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
            gnome-terminal
            gnome-console
        ]);
    };

    system.stateVersion = "24.05"; # Did you read the comment?

}
