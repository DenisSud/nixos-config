{config, pkgs, ...}:
{

  hardware = {

    bluetooth.enable = true;

    pulseaudio.enable = false;

    cpu.amd.updateMicrocode = true;

    graphics.enable = true;
    
    nvidia-container-toolkit.enable = true;

    nvidia = {
      open = true;
      powerManagement.enable = true;
      powerManagement.finegrained = false;
      modesetting.enable = true;
      package = config.boot.kernelPackages.nvidiaPackages.vulkan;
    };

  };

}
