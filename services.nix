{config, pkgs, ...}:
{

  services = {

    nvidia-suspend.enable = true;

    logind  = {
      # lidSwitch = "suspend";
      # lidSwitchDocked = "ignore";
      # handleLidSwitch = "suspend";
      # handleLidSwitchDocked = "ignore";
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

    tor = {
      enable = true;
      client.enable = true;
      torsocks.enable = true;
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };

}
