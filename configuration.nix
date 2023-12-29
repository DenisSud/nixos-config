{ config, pkgs, ... }:

{
  
 
  system = {
    stateVersion = "23.05";
    activationScripts.linkBash = {
      text = ''
        ln -sf ${pkgs.bash}/bin/bash /bin/bash
      '';
    };

  };
 
 
  nix = {
    optimise.automatic = true;
    settings.experimental-features = [ "nix-command" "flakes" ];

  };

 
  environment = {
    shells = with pkgs; [ zsh bash dash ];
    binsh = "${pkgs.dash}/bin/dash";

    sessionVariables = rec {
      NIXOS_OZONE_WL = "1";
      XDG_CACHE_HOME  = "$HOME/.cache";
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_DATA_HOME   = "$HOME/.local/share";
      XDG_STATE_HOME  = "$HOME/.local/state";

      # Not officially in the specification
      XDG_BIN_HOME = "$HOME/.local/bin";
      PATH = [ 
        "${XDG_BIN_HOME}"
      ];
    };

  };



  services = {

    xserver = {
      enable = true;
      desktopManager.xterm.enable = true;
      displayManager.defaultSession = "none+i3";


      windowManager.i3 = {
        enable = true;
        extraPackages = with pkgs; [
          dmenu #application launcher most people use
          i3status # gives you the default i3 status bar
          i3lock #default i3 screen locker
          i3blocks #if you are planning on using i3blocks over i3status
        ];
      };


      videoDrivers = [ "nvidia" ];
       # Enable touchpad support (enabled default in most desktopManager).
      libinput.enable = true;

    };

    #sound
    pipewire = {
      enable = true;
      audio.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
      wireplumber.enable = true;
    };

    # Enable CUPS to print documents.
    #printing.enable = true;

    #openssh = {
      #enable = true;
      #ports = [ 22552 ];
      #settings = {
        #PermitRootLogin = "no";
        #PasswordAuthentication = false;
        #KbdInteractiveAuthentication = false;
    #};

    

  };


  #bootloader
  boot = {
    kernelPackages = pkgs.linuxPackages_latest; #most update kernel    
    loader = {
      systemd-boot.enable = false;
      grub = {
        enable = true;
        efiSupport = true;
        useOSProber = true;
        #efiInstallAsRemovable = true; # in case canTouchEfiVariables doesn't work for your system
        device = "nodev";
      };
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
    };
  
    initrd.kernelModules = [ "nvidia" ]; 
    blacklistedKernelModules = ["nouveau"];
  };


  hardware = {
  
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;

      extraPackages = with pkgs; [
        rocm-opencl-icd
        rocm-opencl-runtime
      ];
      
    };

    nvidia = {
      modesetting.enable = true;
      open = false;
      nvidiaSettings = true;
      dynamicBoost.enable = true; 
      powerManagement.enable = false;
      powerManagement.finegrained = true;
      nvidiaPersistenced = true;


      prime = { 
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };

        amdgpuBusId = "PCI:7:0:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };

    logitech.wireless.enable = true;
    pulseaudio.enable = false;

    #Bluetooth
    #bluetooth.enable = true;

  };


  networking = {
    
    hostName = "nixos"; # Define your hostname.
    networkmanager.enable = true;  # Easiest to use and most distros use this by default.
    enableIPv6 = true;

    nat = {
      enable = true;
      enableIPv6 = true;
      externalInterface = "enp3s0";
      internalInterfaces = [ "wg0" ];
    };

    firewall = {
      enable = true;
      #allowedTCPPorts = [ 53 ];
      #allowedUDPPorts = [ 53 51820 ];
    };

    
  };
  


  #time 
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  console = { 
    font = "Lat2-Terminus16";
      keyMap = "us";
  };




  programs = {
    zsh.enable = true;

  };





  #users
  users = {
    mutableUsers = true;
    groups = {
      samuel.gid = 1000;
    };
   
    users.samuel = {
      isNormalUser = true;
      home = "/home/samuel";
      shell = pkgs.zsh;
      uid = 1000;
      group = "samuel";
      extraGroups = [ "wheel" "networkmanager" "libvirtd" ]; # Enable ‘sudo’ for the user.
    };
  };



  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 32*1024;
  }];


  security = {
  
    sudo = {
      enable = true;
      extraRules = [{
        commands = [
          {
          command = "${pkgs.systemd}/bin/systemctl suspend";
          options = [ "NOPASSWD" ];
          }
          {
          command = "${pkgs.systemd}/bin/reboot";
          options = [ "NOPASSWD" ];
          }
          {
          command = "${pkgs.systemd}/bin/poweroff";
          options = [ "NOPASSWD" ];
          }
        ];
        groups = [ "wheel" ];
      }];
    };
    
    #emulator memory
    pam.loginLimits = [
      {domain = "*";type = "hard";item = "memlock";value = "unlimited";}
      {domain = "*";type = "soft";item = "memlock";value = "unlimited";}
    ];

    #sound
    rtkit.enable = true;

  };








}
