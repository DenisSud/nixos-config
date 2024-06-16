{config, pkgs, ...}:
{

  services = {

    xserver = {
      enable = true;
      xkb.options = "caps:swapescape";
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
      videoDrivers = [ "nvidia" "amdgpu" ];
      excludePackages = (with pkgs; [
          xterm
      ]);
    };

    ollama = {
      enable = true;
      # acceleration = "cuda";
    };

    openssh.enable = true;

    pipewire = {
      enable = true;
      audio.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
      wireplumber.enable = true;
    };
  };

}
