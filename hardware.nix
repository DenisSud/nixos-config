{config, pkgs, ...}:
{

  hardware = {

    bluetooth.enable = true;

    pulseaudio.enable = false;

    cpu.amd.updateMicrocode = true;

    graphics.enable = true;

    nvidia-container-toolkit.enable = true;

    nvidia = {
      modesetting.enable = true;
      prime = {
        offload = { # enable for better power managment
			    enable = true;
		    };
      };
    };

  };

}
