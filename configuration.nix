{ config, pkgs, inputs, ... }:

{

  programs = {
    zsh.enable = true;
    nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 4d --keep 3";
      flake = "/home/denis/nixos";
    };
  };

  virtualisation.docker.enable = true;

  imports =
    [
      ./hardware-configuration.nix
      ./modules/hardware.nix
      # ./modules/rice.nix
      ./modules/services.nix
      ./modules/users.nix
      inputs.home-manager.nixosModules.default
    ];

  home-manager.users.denis = import ./home.nix;
  home-manager.backupFileExtension = "backup";

	fileSystems."/".options = [ "noatime" ];
	fileSystems."/boot".options = [ "noatime" ];

	fileSystems."/".autoResize = false;
	fileSystems."/boot".autoResize = false;

  nix = {
    optimise.automatic = true;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  # Set your time zone.
  time.timeZone = "Europe/Moscow";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
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

  boot = {
    loader.systemd-boot.configurationLimit = 10;
    blacklistedKernelModules = [ "nouveau" "amd_pstate" ];
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    kernelParams = [ "amd_iommu=pt" "iommu=soft" ];
  };

  networking = {
    hostName = "g14-nixos";
  };

  environment = {
    variables = {
      EDITOR = "neovim";
      OPENAI_BASE_URL = "https://localhost:11434/v1";
    };

    systemPackages = with pkgs; [
      ffmpeg
      gnomeExtensions.vitals
      supergfxctl
      asusctl
      libappimage
      curl
      firefox
      fzf
      git
      xclip
      btop
      nvtopPackages.full
      neofetch
    ];

    gnome.excludePackages = (with pkgs; [
      gnome-text-editor
      gnome-console
      gnome-photos
      gnome-tour
      gnome-connections
      simple-scan
      gnome-usage
    ]) ++
    (with pkgs.gnome; [
      gnome-calculator
      gnome-system-monitor
      cheese
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
  };

  # Enable sound.
  sound.enable = true;


  nixpkgs = {

		config = {
    	allowUnfree = true;
  	};
    config.permittedInsecurePackages = [
      "electron-25.9.0"
    ];

  };

  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?

}
