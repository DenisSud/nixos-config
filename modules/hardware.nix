{config, pkgs, ...}:
{
  
  hardware = {
  
    bluetooth.enable = true;

    pulseaudio.enable = false;

    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      powerManagement.finegrained = true;
      open = false;
      package = config.boot.kernelPackages.nvidiaPackages.production;
      nvidiaSettings = true;
      prime = {
        sync.enable = false; # enable for maximum performance
        offload = { # enable for better power managment
			    enable = true;
			    enableOffloadCmd = true;
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
