{config, pkgs, ...}:
{

  services = {

    asusd = {
      enable = true;
      enableUserService = true;
    };

    fprintd = {
      enable = true;
      tod.enable = true;
      tod.driver = pkgs.libfprint-2-tod1-goodix;
    };

    supergfxd.enable = true;

    ollama = {
      enable = true;
      acceleration = "cuda";
    };

    xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
      videoDrivers = [ "nvidia" "mesa" ];
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

}
