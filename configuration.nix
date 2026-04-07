{
  inputs,
  config,
  pkgs,
  ...
}:

{
  imports = [ ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "25.05";

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking = {
    networkmanager.enable = true;
    firewall.enable = true;
  };

  services.openssh.enable = true;
  services.printing = {
    enable = true;
    drivers = with pkgs; [ epson-escpr ];
    browsing = false;
  };

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

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa = { enable = true; support32Bit = true; };
    pulse.enable = true;
  };
  services.pulseaudio.enable = false;
  services.flatpak.enable = true;
  security.polkit.enable = true;

  services.udev.extraRules = ''
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", MODE="0660", GROUP="users", TAG+="uaccess"
  '';

  stylix = {
    enable = true;
    image = ./wallpaper.png;
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/black-metal.yaml";
  };

  fonts = {
    packages = with pkgs; [ nerd-fonts.jetbrains-mono ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "JetBrainsMono Nerd Font Mono" ];
        sansSerif = [ "Inter" ];
        serif = [ "Inter" ];
      };
      cache32Bit = true;
      hinting = { enable = true; style = "slight"; };
    };
  };

  home-manager.backupFileExtension = "backup";
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users.denis = import ./modules/home.nix;
  };

  users.users.denis = {
    isNormalUser = true;
    description = "denis";
    extraGroups = [ "networkmanager" "wheel" "docker" "i2c" "seat" ];
    shell = pkgs.fish;
    packages = with pkgs; [
      vlc
      fastfetch
      onefetch
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
      zed-editor
      code-cursor
      lazygit
      lazydocker
      gnome-tweaks
      yandex-music
      impression
      mangohud
      anki
      vial
      opencode
      claude-code
      pi-coding-agent
      gnomeExtensions.control-monitor-brightness-and-volume-with-ddcutil
      gnomeExtensions.caffeine
      gnomeExtensions.clipboard-indicator
      gnomeExtensions.blur-my-shell
      gnomeExtensions.gsconnect
    ];
  };

  environment.systemPackages = with pkgs; [
    inputs.rip.packages.${pkgs.system}.default

    # system essentials
    ntfs3g lsof corefonts ffmpeg btop-cuda
    git git-lfs gcc pkg-config wget curl
    tmux zellij file dig iw tree neovim
    bat jq ddcutil fd eza

    # LSP servers
    vtsls
    vscode-langservers-extracted
    emmet-language-server
    gopls
    rust-analyzer
    lua-language-server
    basedpyright
    nil

    # formatters
    nixfmt
    stylua
    prettierd
    gofumpt
    gotools
    rustfmt
    isort
    black
  ];

  programs = {
    steam.enable = false;
    steam.gamescopeSession.enable = true;
    mtr.enable = true;

    nh = {
      enable = true;
      flake = "/home/denis/NixOS";
      clean = { enable = true; dates = "weekly"; };
    };

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    appimage = { enable = true; binfmt = true; };
    fish.enable = true;
  };
}
