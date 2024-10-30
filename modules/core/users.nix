{ config, pkgs, ... }:

{
  users.users.denis = {
    isNormalUser = true;
    description = "Denis";
    password = "jkl;'";
    extraGroups = [
      "wheel"           # Enable 'sudo' for the user
      "networkmanager"  # Network management
      "docker"          # Docker management
      "audio"          # Audio devices
      "video"          # Video devices
      "input"          # Input devices
    ];

    # Default packages for your user
    packages = with pkgs; [
      # These can be moved to home-manager later
      # Here are just the essential ones that you might need
      # before home-manager is set up
      firefox           # Browser for system recovery if needed
      kitty
      wget
      curl
      git
      vim
    ];

    shell = pkgs.nushell;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable zram swap
  zramSwap.enable = true;

  # Enable docker
  virtualisation.docker = {
    enable = true;
    enableNvidia = true;
    extraOptions = "--default-runtime=nvidia";

    daemon.settings = {
      "data-root" = "/home/denis/Docker";
    };

    autoPrune = {
      enable = true;
      dates = "daily";
    };
  };
}
