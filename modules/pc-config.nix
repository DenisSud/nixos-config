{ config, pkgs, ... }:

{
  # PC-only settings (moved from your old configuration.nix)
  networking.hostName = "pc";
  networking.interfaces.eno1.wakeOnLan.enable = true;

  # firewall and extra ports for pc
  networking.firewall.allowedTCPPorts = [ 1111 11434 8080 ];

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
}
