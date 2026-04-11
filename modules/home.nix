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

      # Pi coding agent — declarative config only
      # (models.json, auth.json, sessions/ are per-device runtime state)
      ".pi/agent/settings.json".source = ../dotfiles/.pi/agent/settings.json;
      ".pi/agent/skills".source = ../dotfiles/.pi/agent/skills;
      ".pi/agent/extensions".source = ../dotfiles/.pi/agent/extensions;
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
        set -g fish_greeting

        if type -q starship
          starship init fish | source
        end
        if type -q zoxide
          zoxide init fish | source
        end

        alias vi="nvim"
        alias ls='eza'
        alias ll='eza -lbF --git'
        alias la='eza -lbhHigUmuSa --git'
        alias lt='eza --tree --level=2'

        # Source per-device secrets (API keys, etc.)
        # Create ~/.env with lines like: set -gx OPENAI_API_KEY "sk-..."
        if test -f ~/.env
          source ~/.env
        end

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
      };
    };

    home-manager.enable = true;
  };
}
