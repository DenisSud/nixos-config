{ config, pkgs, ... }:

{
    imports = [
        ./modules/hardware-configuration.nix
        ./modules/nixvim.nix
    ];

    virtualisation.docker = {
        enable = true;
        enableNvidia = true;
        extraOptions = "--default-runtime=nvidia";
    };

    programs = {

        firefox = {
            enable = true;
        };

        nh = {
            enable = true;
            clean.enable = true;
            clean.extraArgs = "--keep-since 3d --keep 3";
            flake = "/home/denis/NixOS";
        };

        git = {
            enable = true;
            lfs.enable = true;
        };
    };

    home-manager.users.denis = import ./modules/home.nix;

    xdg = {
        mime.enable = true;
        portal.enable = true;
    };

    stylix = {
        enable = true;
        image = ./modules/wallpaper/drip.jpg;

        polarity = "dark";
        base16Scheme = "${pkgs.base16-schemes}/share/themes/da-one-gray.yaml";

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
    boot = {
        loader = {
            efi = {
                canTouchEfiVariables = true;
                efiSysMountPoint = "/boot"; # ← use the same mount point here.
            };
            grub = {
                efiSupport = true;
                device = "nodev";
            };
        };
        kernelModules = [ "v4l2loopback" ];
        extraModulePackages = [ pkgs.linuxPackages.v4l2loopback ];
        extraModprobeConfig = ''
            options v4l2loopback exclusive_caps=1 card_label="Virtual Webcam" video_nr=0
        '';
    };

    networking.hostName = "g14"; # Define your hostname.
    networking.firewall.enable = false;
    networking.firewall.allowedTCPPorts = [ 22 ];

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

        ollama = {
            enable = true;
            acceleration = "cuda";
        };

        interception-tools.enable = true;

        xserver = {
            enable = true;

            displayManager = { 
                # gdm.enable = true;
                defaultSession = "none+i3"; 
                lightdm = { 
                    enable = true; 
                    greeter.enable = false; 
                };
            };

            desktopManagergnome.enable = true;
            windowManager.i3.enable = true;

            services.displayManager.sddm.enable = true;
            services.desktopManager.plasma6.enable = true;

            videoDrivers = [ "nvidia" ];
            excludePackages = (with pkgs; [
                xterm
            ]);
        };

        openssh = {
            enable = true;  # Enable the SSH service
            ports = [ 22 ]; # Specify the port for SSH (default is 22)
            settings = {
                PermitRootLogin = "prohibit-password";
                PasswordAuthentication = true;
                PubkeyAuthentication = true;
            };
        };


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

        nvidia-container-toolkit.enable = true;

        nvidia = {

            modesetting.enable = true;
            package = config.boot.kernelPackages.nvidiaPackages.production;

            open = false;

            powerManagement.enable = true;
            powerManagement.finegrained = true;

            nvidiaSettings = true;

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

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.denis = {
        isNormalUser = true;
        password = "jkl;'";
        extraGroups = [ "wheel" "networkmanager" "docker" ];
        packages = with pkgs; [
            # Apps
	    home-manager
            evince
            open-interpreter
            nvidia-container-toolkit
            cudaPackages.cudatoolkit
            discord
            kitty
            obs-studio
            onefetch
            neofetch
            ticktick
            obsidian
            zed-editor
            telegram-desktop

            # Shell stuff
            nb
            go
            git
            vlc
            gcc
            dust
            nodejs
            rustup
            zoxide
            docker
            gitui
            oxker
            ripgrep
            git-lfs
            docker-compose
            wireguard-tools
        ];
        shell = pkgs.nushell;
    };

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    environment = {

        variables = {
            EDITOR = "nvim";
            DEFAULT_VENDOR = "Ollama";
            DEFAULT_MODEL = "llama3.2:latest";
            OLLAMA_MODELS = "/home/denis/Ollama-models";
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
            totem # video player
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
            gnome-software
            gnome-music
            gnome-characters
            gnome-weather
            gnome-clocks
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
