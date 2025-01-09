{ lib, config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules
  ];

  myconfig = {
    base = {
      enable = true;
      hostname = "g14";
    };
    desktop.enable = true;
  };

  # G14 specific configurations
  services = {
    asusd.enable = true;
    supergfxd.enable = true;
  };

    nixpkgs.config = {
        allowUnfree = true;
    };

    environment = {
        systemPackages = with pkgs; [
            gnome-tweaks
                neovim
                fzf
                gcc
                curl
                wget
                bat
                dust
                htop
                git
                git-lfs
                ghostty
                # nvtopPackages.full
                gnomeExtensions.pip-on-top
                gnomeExtensions.gpu-supergfxctl-switch
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
        image = lib.mkDefault ../../wallpapers/color.png;
        polarity = lib.mkDefault "dark";
        base16Scheme = lib.mkDefault "${pkgs.base16-schemes}/share/themes/vesper.yaml";
    };

    specialisation = {
    };

    users.users.denis = {
        isNormalUser = true;
        shell = pkgs.nushell;
        description = "denis";
        initialPassword = "password";
        extraGroups = [ "networkmanager" "wheel" "docker" ];
        packages = with pkgs; [
            # Base packages
            galaxy-buds-client
            telegram-desktop
            seahorse
            eyedropper
            obsidian
            bottles
            alpaca
            gimp

            # Shell packages
            zed-editor
            fabric-ai
            starship
            carapace
            ripgrep
            nushell
            harper
            zoxide
            rip2
            tree
            dust
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
