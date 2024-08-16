{config, pkgs, ...}:
{

  hardware = {

    bluetooth.enable = true;

    pulseaudio.enable = false;

    cpu.amd.updateMicrocode = true;

    nvidia = {
      modesetting.enable = true;
      prime = {
        offload = { # enable for better power managment
			    enable = true;
		    };
      };
    };

    opengl.enable = true;

  };

}
