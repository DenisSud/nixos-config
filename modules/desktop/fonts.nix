{ config, lib, pkgs, ... }:

{
  # Enable fonts configuration
  fonts = {
    # Enable default fonts
    enableDefaultPackages = true;

    # Font packages to install
    packages = with pkgs; [
      # Icon fonts
      material-design-icons
      font-awesome

      # Nerd fonts
      (nerdfonts.override {
        fonts = [
          "JetBrainsMono"
          "FiraCode"
          "Hack"
        ];
      })

      # General fonts
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      liberation_ttf
      fira
      fira-code
      jetbrains-mono
    ];

    # Font configuration
    fontconfig = {
      defaultFonts = {
        serif = [ "Noto Serif" "Noto Color Emoji" ];
        sansSerif = [ "Noto Sans" "Noto Color Emoji" ];
        monospace = [ "JetBrainsMono Nerd Font" "Noto Color Emoji" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}
