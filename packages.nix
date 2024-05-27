{ pkgs, inputs, ... }:


{
  nixpkgs.config.allowUnfree = true;


  # List packages installed in system profile. To search, run:
  # $ nix search wget



  # And ensure gnome-settings-daemon udev rules are enabled 
  services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];

  #minimal gnome
  environment.gnome.excludePackages = (with pkgs; [
    gnome-console
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


    switcheroo-control #dbus for dual gpu

    #gmome
    gnomeExtensions.appindicator
    gnomeExtensions.supergfxctl-gex
    # gnomeExtensions.screen-rotate # 2 in 1 extension
    gnomeExtensions.rounded-window-corners # waiting for update >:(
    gnomeExtensions.auto-move-windows
    gnomeExtensions.vitals
    gnome.gnome-tweaks

    #terminal 
    blackbox-terminal
    warp-terminal

    #video player
    celluloid

    #zsh shit
    starship

    #recording 
    obs-studio

    #browser
    firefox

    #text editor
    helix

    #note taking
    obsidian

    #lsps
    rust-analyzer
    gopls
    python311Packages.python-lsp-server
    rocmPackages.llvm.clang-unwrapped
    rustup

    #xbox controllers
    # xboxdrv

    #discord
    # webcord


    #libraries
    linuxHeaders
    linux-firmware
    gjs

    #utilities
    git
    gh
    pywal
    killall
    ffmpeg
    wget
    unzip
    btop
    fzf
    neofetch

    appimage-run #runs appimages 
    steam-run #runs linux binaries


  ];


  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    };
  };


  #asus system services
  services = {
    asusd = {
      package = inputs.asusctl.legacyPackages.x86_64-linux.asusctl;
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
