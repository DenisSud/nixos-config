{ config, lib, pkgs, ... }:

{
  # GTK configuration
  stylix.enable = true;
  stylix = {
    image = ./wallpaper/magic_tree.png;
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/classic-dark.yaml";

    fonts = {
      serif = {
        package = pkgs.nerdfonts;
        name = "JetBrainsMono Nerd Font";
      };
      sansSerif = {
        package = pkgs.nerdfonts;
        name = "JetBrainsMono Nerd Font";
      };
      monospace = {
        package = pkgs.nerdfonts;
        name = "JetBrainsMono Nerd Font";
      };
    };
  };

  # Additional themes
  environment.systemPackages = with pkgs; [
    # GTK Themes
    arc-theme
    dracula-theme
    nordic

    # Icons
    papirus-icon-theme
  ];
}
