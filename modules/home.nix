{ lib, config, pkgs, inputs, ... }:
{
  home = {
    username = "denis";
    homeDirectory = "/home/denis";
    stateVersion = "25.05";

# Dotfiles
    file = {
      # Desktop entry for AppImage
      ".local/share/applications/my-app.desktop".text = ''
        [Desktop Entry]
        Version=1.0
        Type=Application
        Name=Helium
        Comment=The Helium Browser
        Exec=appimage-run /home/denis/Helium.AppImage
        Icon=/home/denis/Pictures/Helium-icon.png
        Categories=Utility;
        Terminal=false
        StartupWMClass=my-appimage
      '';
      ".config/nvim".source = ../dotfiles/nvim; # Points to your `dotfiles/nvim` directory
      ".config/starship.toml".source = ../dotfiles/starship.toml;
    };
  };

# Program configurations
  programs = {

    btop = {
      package = pkgs.btop-cuda;
      enable = true;
    };

    fzf = {
      enable = true;
      enableFishIntegration = true;
    };

    fish = {
      enable = true;
      interactiveShellInit = ''
        # starship prompt
        if type -q starship
          starship init fish | source
        end

        # zoxide
        if type -q zoxide
          zoxide init fish | source
        end

        alias v="nvim"
      '';
    };

    ghostty = {
      enable = true;
      installBatSyntax = true;
      installVimSyntax = true;
      enableFishIntegration = true;
      settings = {
        theme = "dark:Black Metal,light:Alabaster";
        font-size = 12;
        font-family = "JetBrainsMono Nerd Font Mono";
        shell-integration-features = "sudo";
        keybind = [
          "ctrl+h=goto_split:left"
          "ctrl+l=goto_split:right"
          "ctrl+j=goto_split:down"
          "ctrl+k=goto_split:up"
        ];
      };

    };

    home-manager.enable = true;
  };
}
