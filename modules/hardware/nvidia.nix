{ config, lib, pkgs, ... }:

{
  # Common NVIDIA configuration
  hardware.nvidia = {
    # Required to load NVIDIA kernel module on boot
    modesetting.enable = true;

    # Enable power management (do not disable this unless you have a reason to)
    powerManagement = {
      enable = true;
      finegrained = true;
    };

    # Use the NVidia settings menu
    nvidiaSettings = true;

    # Choose the driver version
    package = config.boot.kernelPackages.nvidiaPackages.production;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;
  };

  # NVIDIA-specific environment variables
  environment.sessionVariables = {
    # For nvidia-settings
    __GL_SYNC_TO_VBLANK = "0";
    # Hardware acceleration on NVIDIA
    LIBVA_DRIVER_NAME = "nvidia";
    # Hardware acceleration on NVIDIA
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };

  # NVIDIA-specific options for X11
  services.xserver.videoDrivers = [ "nvidia" ];
}
