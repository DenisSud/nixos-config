{config, pkgs, ...}:
{
  
  hardware = {
  
    bluetooth.enable = true;

    pulseaudio.enable = false;

    nvidia = {
      modesetting.enable = true;
      prime = {
        sync.enable = true; # enable for maximum performance
        offload = { # enable for better power managment
			    enable = false;
		    };
        amdgpuBusId = "PCI:4:0:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };
    
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };
  };

}
