{config, pkgs, ...}:
{
  
  hardware = {
  
    bluetooth.enable = true;

    pulseaudio.enable = false;

    cpu.amd.updateMicrocode = true;

    nvidia = {
      modesetting.enable = true;
      prime = {
        sync.enable = false; # enable for maximum performance
        offload = { # enable for better power managment
			    enable = true;
		    };
        amdgpuBusId = "PCI:4:0:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };
    
  };

}
