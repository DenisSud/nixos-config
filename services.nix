{config, pkgs, ...}:
{

  services = {

    gnome.gnome-browser-connector.enable = true;

		supergfxd.enable = true;

    xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
      videoDrivers = [ "nvidia" "amdgpu" ];
      excludePackages = (with pkgs; [
          xterm
      ]);
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
