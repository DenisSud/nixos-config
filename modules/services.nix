{config, pkgs, ...}:
{

  services = {

		journald= {
			extraConfig = ''
				SystemMaxUse=1G
			'';
		};

    thermald.enable = true;

    tlp = {
      settings = {
        CPU_BOOST_ON_AC = 1;
        CPU_BOOST_ON_BAT = 0;
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      };
    };

    gnome.gnome-browser-connector.enable = true;

    ollama = {
      enable = true;
      # acceleration = "cuda";
    };

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
