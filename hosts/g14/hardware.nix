{ config, lib, pkgs, ... }:

{
  boot = {
    kernelModules = [ "kvm-amd" "v4l2loopback" ];
    extraModulePackages = [ pkgs.linuxPackages.v4l2loopback ];
    extraModprobeConfig = ''
      options v4l2loopback exclusive_caps=1 card_label="Virtual Webcam" video_nr=0
    '';

    initrd = {
      availableKernelModules = [ "nvme" "xhci_pci" "usb_storage" "usbhid" "sd_mod" ];
      kernelModules = [ ];
    };
  };

  # File systems configuration for your G14
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/1f15bc9d-7c0b-4abe-bfb5-a682aa55bf5d";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/E026-0C48";
      fsType = "vfat";
    };

    "/home" = {
      device = "/dev/disk/by-uuid/bd2a2e94-1207-47b8-b5b9-a4c33f72c46e";
      fsType = "ext4";
    };
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/b37bebca-b1a8-4005-ae82-83fa5a6ae8dc"; }
  ];

  # Hardware specific settings for G14
  hardware = {
    bluetooth.enable = true;
    pulseaudio.enable = false;

    graphics = {
      enable = true;
      enable32Bit = true;
    };

    nvidia-container-toolkit.enable = true;

    nvidia = {
      modesetting.enable = true;
      package = config.boot.kernelPackages.nvidiaPackages.production;
      open = false;
      powerManagement = {
        enable = true;
        finegrained = true;
      };
      nvidiaSettings = true;

      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
        amdgpuBusId = "PCI:4:0:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
