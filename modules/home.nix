{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
{
  home = {
    username = "denis";
    homeDirectory = "/home/denis";
    stateVersion = "25.05";

    file = {
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
      ".config/nvim".source = ../dotfiles/nvim;
      ".config/starship.toml".source = ../dotfiles/starship.toml;
    };

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      NIXOS_OZONE_WL = "1";
    };
  };

  programs = {
    fzf = {
      enable = true;
      enableFishIntegration = true;
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    fish = {
      enable = true;
      interactiveShellInit = ''
        if type -q starship
          starship init fish | source
        end
        if type -q zoxide
          zoxide init fish | source
        end
        if type -q atuin
          atuin init fish | source
        end

        alias v="nvim"
        alias cl="clear"
        alias ls='eza'
        alias ll='eza -lbF --git'
        alias la='eza -lbhHigUmuSa --git'
        alias lt='eza --tree --level=2'

        set -gx FZF_DEFAULT_COMMAND 'fd --type f'
        set -gx FZF_CTRL_T_COMMAND 'fd --type f'
        set -gx FZF_ALT_C_COMMAND 'fd --type d'
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
