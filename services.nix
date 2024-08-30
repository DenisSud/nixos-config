{config, pkgs, ...}:
{

  services = {

		supergfxd.enable = true;

		ollama = {
		  enable = true;
			acceleration = "cuda";
		};

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
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };

}
