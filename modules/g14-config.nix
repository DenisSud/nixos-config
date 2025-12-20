{ config, pkgs, ... }:

{
  # PC-only settings (moved from your old configuration.nix)
  networking.hostName = "g14";

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
    videoDrivers = [ "nvidia" "amdgpu" ];

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
    package = pkgs.ollama-cuda;
  };

  services.printing.enable = true;

}
