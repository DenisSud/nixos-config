{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules
  ];

  myconfig = {
    base = {
      enable = true;
      hostname = "g14";
    };
    desktop.enable = true;
  };

  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
    grub = {
      enable = true;
      devices = [ "nodev" ];
      efiSupport = true;
      useOSProber = true;
    };
  };

  # G14 specific configurations
  services = {
    asusd.enable = true;
    supergfxd.enable = true;
  };

  nixpkgs.config = {
      allowUnfree = true;
  };

  # Hardware-specific settings
  powerManagement.cpuFreqGovernor = "powersave";
  hardware = {
    bluetooth.enable = true;

    graphics = {
      enable = true;
      enable32Bit = true;
    };

    nvidia = {
      modesetting.enable = true;
      package = config.boot.kernelPackages.nvidiaPackages.production;
      open = false;
      powerManagement = {
        enable = true;
        finegrained = true;
      };
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

  # User configuration
  stylix = {
    enable = true;
    image = lib.mkDefault ../../wallpapers/FrenchRevolution.jpg;
    polarity = lib.mkDefault "dark";
    base16Scheme = lib.mkDefault "${pkgs.base16-schemes}/share/themes/vesper.yaml";
  };

  specialisation = {
  };

  users.users.denis = {
    isNormalUser = true;
    shell = pkgs.nushell;
    description = "denis";
    initialPassword = "password";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [
      # Base packages
      galaxy-buds-client
      telegram-desktop
      eyedropper
      seahorse
      obsidian
      bottles

      # Shell packages
      texliveBasic
      zed-editor
      fabric-ai
      starship # shell prompt
      carapace # shell completion library
      ripgrep # better grep
      nushell # the best shell
      harper # auto-correct lsp
      zoxide # better cd
      pandoc
      yazi
      rip2 # better rm
      tree # better ls
    ];
  };

  home-manager = {
    extraSpecialArgs = {inherit inputs;};
    backupFileExtension = "backup";
    users = {
      "denis" = import ./home.nix;
    };
  };

  system.stateVersion = "24.05"; # Did you read the comment?

}
