{ config, pkgs, ... }:

{
  # PC-only settings (moved from your old configuration.nix)
  networking.hostName = "pc";

  # firewall and extra ports for pc
  networking.firewall.allowedTCPPorts = [ 1111 11434 8080 ];

  # ==============================
  # 🎮  Hardware & Graphics
  # ==============================
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };

    nvidia = {
      modesetting.enable = true;
      open = true;
    };

    nvidia-container-toolkit.enable = true;
  };


  # ==============================
  # Desktop Environment (GNOME + X11)
  # ==============================
  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];

    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;

    xkb = {
      layout = "us";
      variant = "";
    };
  };
  services.ollama = {
    host = "0.0.0.0";
    enable = true;
    openFirewall = true;
    acceleration = "cuda";
  };



  services.printing.enable = true;


  # any other PC-only things you want to keep separate can go here
}
