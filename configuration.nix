{ config, pkgs, ... }:

{
  # ==============================
  # 🖥️  Imports & Core Settings
  # ==============================
  imports = [ ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "25.05";


  # ==============================
  # ⚙️  Bootloader
  # ==============================
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };


  # ==============================
  # 🌐  Networking
  # ==============================
  networking = {
    networkmanager.enable = true;
    firewall.enable = true;
  };

  services.openssh.enable = true;


  # ==============================
  # 🌍  Locale & Time
  # ==============================
  time.timeZone = "Europe/Moscow";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "ru_RU.UTF-8";
      LC_IDENTIFICATION = "ru_RU.UTF-8";
      LC_MEASUREMENT = "ru_RU.UTF-8";
      LC_MONETARY = "ru_RU.UTF-8";
      LC_NAME = "ru_RU.UTF-8";
      LC_NUMERIC = "ru_RU.UTF-8";
      LC_PAPER = "ru_RU.UTF-8";
      LC_TELEPHONE = "ru_RU.UTF-8";
      LC_TIME = "ru_RU.UTF-8";
    };
  };


  virtualisation.docker.enable = true;


  # ==============================
  # 🔊  Audio (PipeWire)
  # ==============================
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
  };

  services.pulseaudio.enable = false;  # PipeWire replaces this
  services.flatpak.enable = true;
  
  # For ferris sweep keyboard
  services.udev.extraRules = ''
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", MODE="0660", GROUP="users", TAG+="uaccess"
  '';

  # Styling
  stylix = {
    enable = true;
    image = ./wallpaper.png;
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/black-metal.yaml";
  };

  # ==============================
  # 👤  User Accounts
  # ==============================
  home-manager.backupFileExtension = "backup";
  home-manager.users.denis = {
    # import a separate home.nix file for clarity and easier reuse across machines
    imports = [ ./modules/home.nix ];
  };
  users.users.denis = {
    isNormalUser = true;
    description = "denis";
    extraGroups = [ "networkmanager" "wheel" "docker" "i2c" ];
    shell = pkgs.fish;
    packages = with pkgs; [
      vlc
      fastfetch
      onefetch
      rip2
      codex
      lima
      unzip
      fzf
      dust
      ripgrep
      starship
      obsidian
      vscode
      ghostty
      fragments
      telegram-desktop
      xclip
      zoxide
      libreoffice
      # jellyfin-media-player
      zed-editor
      lazygit
      lazydocker
      gnome-tweaks
      yandex-music
      impression
      anki

      vial
      # CLI ai tools
      opencode
      # GNOME Extensions
      gnomeExtensions.brightness-control-using-ddcutil
      gnomeExtensions.caffeine
      gnomeExtensions.clipboard-indicator
      gnomeExtensions.blur-my-shell
      gnomeExtensions.gsconnect
    ];
  };


  # ==============================
  # 📦  System-Wide Packages
  # ==============================
  environment.systemPackages = with pkgs; [
    # System essentials
    ntfs3g
    corefonts
    ffmpeg
    btop-cuda
    git
    git-lfs
    gcc
    pkg-config
    wget
    curl
    tmux
    zellij
    file
    dig
    iw
    tree
    neovim
    bat
    jq
    ddcutil
    fd
    eza
  ];


  # ==============================
  # 🐟  User Programs & Shells
  # ==============================
  programs = {
    steam.enable = false;
    mtr.enable = true;

    nh = {
      enable = true;
      flake = "/home/denis/NixOS";
      clean = {
        enable = true;
        dates = "weekly";
      };
    };

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    appimage = {
      enable = true;
      binfmt = true;
    };
    fish.enable = true;
  };
}
