{ config, lib, pkgs, ... }:

with lib;
{
  options.myconfig.desktop = {
    enable = mkEnableOption "Enable desktop configuration";
  };

  config = mkIf config.myconfig.desktop.enable {
    services.xserver = {
      enable = true;
      excludePackages = [ pkgs.xterm ];
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };

    programs = {
      steam = {
        enable = true;
        gamescopeSession.enable = true;
      };
      gamemode.enable = true;
    };

    services = {
      flatpak.enable = true;
      printing.enable = true;
      avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
      };
    };

    environment.systemPackages = with pkgs; [
      gnome-tweaks
      ghostty
      gnomeExtensions.pip-on-top
      gnomeExtensions.caffeine
      gnomeExtensions.clipboard-indicator
      gnomeExtensions.blur-my-shell
      gnomeExtensions.vitals
    ];
  };
}
