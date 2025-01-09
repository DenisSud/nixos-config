{ config, lib, pkgs, ... }:

with lib;
{
  options.myconfig.base = {
    enable = mkEnableOption "Enable base configuration";
    hostname = mkOption {
      type = types.str;
      description = "Hostname of the machine";
    };
  };

  config = mkIf config.myconfig.base.enable {
    networking = {
      hostName = config.myconfig.base.hostname;
      networkmanager.enable = true;
      firewall.enable = false;
    };

    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    time.timeZone = "Europe/Moscow";
    i18n.defaultLocale = "en_US.UTF-8";

    programs = {
      git = {
        enable = true;
        lfs.enable = true;
      };
      direnv.enable = true;
      nh = {
        enable = true;
        clean.enable = true;
      };
    };

    services.openssh = {
      enable = lib.mkDefault true;
    };

    environment.systemPackages = with pkgs; [
      neovim
      fzf
      gcc
      curl
      wget
      bat
      dust
      htop
      git
      git-lfs
    ];
  };
}
