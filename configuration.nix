{ config, pkgs, ... }:

{
    imports = [
        ./hardware-configuration.nix
    ];

    virtualisation.docker = {
        enable = true;
    };

    programs = {

        firefox = {
            enable = true;
        };

        nh = {
            enable = true;
            flake = "/home/denis/NixOS/";
        };

        git = {
            enable = true;
            lfs.enable = true;
        };
    };

    stylix = {
        enable = true;
        image = ./wallpaper/black-hole.jpeg;
        polarity = "dark";
        base16Scheme = "${pkgs.base16-schemes}/share/themes/black-metal.yaml";
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
                efiSysMountPoint = "/boot/efi"; # ← use the same mount point here.
            };

            grub = {
                default = "saved";
                extraConfig = ''
                  GRUB_SAVEDEFAULT=true
                '';
                enable = true;  # Enable GRUB
                useOSProber = false;  # Enable OS probing for dual-booting
                device = "nodev";  # Use this for EFI systems
                efiSupport = true;  # Enable EFI support
            };
        };
    };

    networking.hostName = "g14"; # Define your hostname.
    networking.firewall.enable = true;

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

        nvidia-container-toolkit.enable = true;

        nvidia = {

            modesetting.enable = true;
            package = config.boot.kernelPackages.nvidiaPackages.vulkan_beta;

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
            nushell
            kitty
            nvidia-container-toolkit
            cudaPackages.cudatoolkit
            obs-studio
            onefetch
            neofetch
            neovim
            flatpak
            ticktick
            obsidian
            zed-editor
            telegram-desktop
            noto-fonts-emoji

            # Shell stuff
            nb
            go
            git
            vlc
            gcc
            nodejs
            rustup
            zoxide
            docker
            lazygit
            lazydocker
            ripgrep
            git-lfs
            fabric-ai
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
            # totem # video player
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
