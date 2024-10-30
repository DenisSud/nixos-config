
{ config, pkgs, ... }:

{
  imports = [ ./hardware.nix ];

  # Set your time zone
  time.timeZone = "Europe/Moscow";

  # Select internationalisation properties
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

  # Basic networking configuration
  networking = {
    hostName = "g14";
    networkmanager.enable = true;
    firewall = {
      enable = false;
      allowedTCPPorts = [ 22 ];
    };
  };

  # System state version - required by NixOS
  system.stateVersion = "24.05";

  # Host-specific packages
  environment.systemPackages = with pkgs; [
    # Add any G14-specific packages here
    # This should be minimal as most packages should go in modules or home-manager
  ];
}
