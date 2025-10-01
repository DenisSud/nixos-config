{ lib, config, pkgs, inputs, ... }:
{
  home = {
    username = "denis";
    homeDirectory = "/home/denis";
    stateVersion = "25.05";

# Dotfiles
    file = {
      ".config/nvim" = {
        source = dotfiles/nvim; # Points to your `dotfiles/nvim` directory
          recursive = true;             # Ensures the entire directory contents are linked/copied
      };
      ".config/starship.toml".source = dotfiles/starship.toml;
    };
  };

# Program configurations
  programs = {

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
      };
    };

    home-manager.enable = true;
  };
}
