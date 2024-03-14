{ config, pkgs, ... }:


{
  nixpkgs.config.allowUnfree = true;
 

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  
  
  
  # And ensure gnome-settings-daemon udev rules are enabled 
  services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];

  #minimal gnome
  environment.gnome.excludePackages = (with pkgs; [
    #gnome-console
    #gnome-text-editor
    #snapshot
    #loupe
    gnome-photos
    gnome-tour
    gnome-connections
    simple-scan
    gnome-usage
  ]) ++ 
  (with pkgs.gnome; [
    #gnome-calculator
    gnome-system-monitor
    #file-roller
    #baobab
    cheese
    #gnome-disk-utility
    gnome-logs
    seahorse
    eog
    gnome-maps
    gnome-font-viewer
    yelp
    gnome-calendar
    gnome-contacts
    gnome-music
    gnome-software
    epiphany # web browser
    geary # email reader
    evince # document viewer
    gnome-characters
    gnome-weather 
    gnome-clocks
    totem # video player
    tali # poker game
    iagno # go game
    hitori # sudoku game
    atomix # puzzle game
  ]);
  
  

  services.xserver.excludePackages = (with pkgs; [ 
    xterm 
  ]);

  environment.systemPackages = with pkgs; [
    

    #gnome exclusive
    switcheroo-control #dbus for dual gpu
    gnomeExtensions.blur-my-shell
    gnomeExtensions.appindicator
    gnomeExtensions.dash-to-dock
    gnomeExtensions.supergfxctl-gex
    gnomeExtensions.screen-rotate # 2 in 1 extension
    gnome.gnome-tweaks
    
	    
    #video player
    celluloid

    #zsh shit
    starship
    
    #recording 
    obs-studio
    
    #communication
    discord 

    #browser
    brave

    #xbox controllers
    xboxdrv
      

   
    #libraries
    ntfs3g
    linuxHeaders
    linux-firmware
    fakeroot
    alsa-utils
    alsa-firmware
    gjs
   
    #utilities
    pywal
    killall
    pamixer
    brightnessctl
    upower
    streamlink
    wget
    unzip
    time
    socat
    rsync
    ripgrep
    fzf
    neofetch
    mpc-cli
    mlocate
    inotify-tools
    groff
    ffmpegthumbnailer
    jellyfin-ffmpeg
    fd
    dialog
    bat
    which
    poppler_utils
    p7zip
    atool
    unrar
    odt2txt
    xlsx2csv
    jq
    mediainfo
    imagemagick
    libnotify
    mangohud
    
   

    
    
    # asus system 
    asusctl
    supergfxctl
    
    #virtual machines
    /*
    virt-manager
    spice spice-gtk
    spice-protocol
    win-virtio
    win-spice
    */

   
    appimage-run #runs appimages 
    steam-run #runs linux binaries

    #gaming
    retroarchFull #emulation
    
    

    

  ];


 

  fonts.packages = with pkgs; [
    font-awesome
    iosevka
    noto-fonts-cjk-sans
    jetbrains-mono
    nerdfonts
    cascadia-code
  ];


  


  #virtmanager
  
  /*
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
        ovmf.enable = true;
        ovmf.packages = [ pkgs.OVMFFull.fd ];
      };
    };
    spiceUSBRedirection.enable = true;
  };
  services.spice-vdagentd.enable = true;
  */



  #podman
  virtualisation = {
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  #asus system services
  services = {
    asusd = {
      enable = true;
      enableUserService = true;
    };
    supergfxd = {
      enable = true;
      settings = {
        vfio_enable = true;
        hotplug_type = "Asus"; 
      };
    };
  };

  systemd.services.supergfxd.path = [ pkgs.pciutils pkgs.lsof ];



  #gnome exclusive services
  services.switcherooControl.enable = true;



  

  
}
