{ config, pkgs, lib, ... }:

{
  # PC-only settings (moved from your old configuration.nix)
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [
    "amd_pstate=active"
    "nvidia_drm.fbdev=1"
    "nvidia_drm.modeset=1"
  ];
  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    "vm.dirty_ratio" = 15;
    "vm.dirty_background_ratio" = 3;
    "vm.overcommit_memory" = 1;
    "vm.min_free_kbytes" = 524288;
    "kernel.numa_balancing" = false;
  };

  networking.hostName = "pc";
  networking.interfaces.eno1.wakeOnLan.enable = true;

  # firewall and extra ports for pc
  networking.firewall.allowedTCPPorts = [ 11434 8080 ];
  networking.firewall.allowedUDPPorts = [ ];
  networking.firewall.allowPing = false;

  # ==============================
  # 🎮  Hardware & Graphics
  # ==============================
  hardware = {
    i2c.enable = true;
    graphics = {
      enable = true;
      enable32Bit = true;
    };

    nvidia = {
      modesetting.enable = true;
      open = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      nvidiaSettings = true;
    };

    nvidia-container-toolkit.enable = true;
  };


  # ==============================
  # Desktop Environment (GNOME + X11)
  # ==============================
  
  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];

    xkb = {
      layout = "us";
      variant = "";
    };
  };
  services = {
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };
  services.ollama = {
    host = "0.0.0.0";
    enable = true;
    openFirewall = true;
    package = pkgs.ollama-cuda;
  };
  services.jellyfin.enable = true;
  services.jellyfin.openFirewall = true;



  services.printing.enable = true;


  # any other PC-only things you want to keep separate can go here

  specialisation = {
    gnome.configuration = {
      system.nixos.tags = [ "gnome" ];
    };

    sway.configuration = {
      services.xserver.desktopManager.gnome.enable = lib.mkForce false;
      services.xserver.displayManager.gdm.enable = lib.mkForce false;

      services.xserver.windowManager.i3.enable = lib.mkForce false;

      services.displayManager.ly.enable = true;

      services.xserver = {
        enable = true;
        displayManager.defaultSession = "sway";
        windowManager.sway = {
          enable = true;
          wrapperFeatures.gtk = true;
          extraPackages = with pkgs; [
            swaylock
            swayidle
            waybar
            wofi
            mako
            pkgs.xdg-desktop-portal-wl
            pkgs.xdg-desktop-portal-gtk
          ];
        };
      };

      xdg.portal = {
        enable = true;
        extraPortals = [ pkgs.xdg-desktop-portal-wl pkgs.xdg-desktop-portal-gtk ];
      };

      environment.sessionVariables = {
        GBM_BACKEND = "nvidia-drm";
        LIBVA_DRIVER_NAME = "nvidia";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        XDG_SESSION_TYPE = "wayland";
      };

      environment.systemPackages = with pkgs; [
        grim
        slurp
        wl-clipboard
        brightnessctl
      ];

      system.nixos.tags = [ "sway" ];
    };
  };
}
