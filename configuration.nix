{
  inputs,
  config,
  pkgs,
  ...
}:

{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "25.05";

  # ── Boot ──────────────────────────────────────────────
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # ── Networking ────────────────────────────────────────
  networking = {
    networkmanager.enable = true;
    firewall.enable = false;
  };

  # ── Time / Locale ─────────────────────────────────────
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

  # ── Hardware / Graphics ───────────────────────────────
  hardware = {
    i2c.enable = true;
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    nvidia-container-toolkit.enable = true;
  };

  # ── Desktop: GNOME ────────────────────────────────────
  services = {
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    xserver.xkb = {
      layout = "us";
      variant = "";
    };
  };

  # ── Audio ──────────────────────────────────────────────
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
  };

  # ── Services ──────────────────────────────────────────
  services = {
    openssh.enable = true;
    flatpak.enable = true;
    ollama = {
      host = "0.0.0.0";
      package = pkgs.ollama-cuda;
    };
  };
  virtualisation.docker.enable = true;
  security.polkit.enable = true;

  # ── Fonts ─────────────────────────────────────────────
  fonts = {
    packages = with pkgs; [
      inter
      nerd-fonts.jetbrains-mono
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "JetBrainsMono Nerd Font Mono" ];
        sansSerif = [ "Inter" ];
        serif = [ "Inter" ];
      };
      cache32Bit = true;
      hinting = {
        enable = true;
        style = "slight";
      };
    };
  };

  # ── User ──────────────────────────────────────────────
  users.users.denis = {
    isNormalUser = true;
    description = "denis";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "i2c"
      "seat"
    ];
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
      gnomeExtensions.caffeine
      gnomeExtensions.clipboard-indicator
      gnomeExtensions.blur-my-shell
      gnomeExtensions.gsconnect
    ];
  };

  # ── System Packages ──────────────────────────────────
  environment.systemPackages = with pkgs; [
    inputs.rip.packages.${pkgs.system}.default

    xray
    proxychains-ng

    # system essentials
    tree-sitter
    claude-code
    pi-coding-agent
    ntfs3g
    lsof
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
    nodejs

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

  # ── Programs ─────────────────────────────────────────
  programs = {
    mtr.enable = true;

    nh = {
      enable = true;
      flake = "/home/denis/nixos-config";
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
      package = pkgs.appimage-run.override {
        extraPkgs = pkgs: [ pkgs.libepoxy ];
      };
    };
    fish.enable = true;
  };

  # ── Home Manager ─────────────────────────────────────
  home-manager.backupFileExtension = "backup";
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users.denis = import ./modules/home.nix;
  };
}
