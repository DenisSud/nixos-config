{ lib, config, pkgs, inputs, ... }:
{
  home = {
    username = "denis";
    homeDirectory = "/home/denis";
    stateVersion = "25.05";

    packages = with pkgs; [
      # Development tools
      btop
      gemini-cli
      podman-compose
      zellij
      starship
      fabric-ai
      ripgrep
      lazygit
      lazysql
      lazydocker 
      git-lfs # Large file storage for git
      zoxide # Better cd
      harper # Grammer language server
      rip2 # Better rm
      bat # Better cat
      jq # Json quiry
      gh # GitHub cli tool
      xh # HTTP requests
      mprocs

# Shell utilities
      unzip
      zip
      cargo
      xclip
      carapace
      zsh
      dust
      pandoc
      nmap
      tree
      gnutar

# For language servers
      nodejs
      python3
      rust-analyzer
      pyright
      gopls
      nil

      # zsh-syntax-highlighting
      zsh-syntax-highlighting
    ];

# Dotfiles
    file = {
      ".config/helix" = {
        source = ../../dotfiles/helix;
        recursive = true;
      };
      ".config/nvim" = {
        source = ../../dotfiles/nvim; # Points to your `dotfiles/nvim` directory
          recursive = true;             # Ensures the entire directory contents are linked/copied
      };
      ".config/starship.toml".source = ../../dotfiles/starship.toml;
      ".config/ghostty/themes/black-metal-gorgoroth".source =
        ../../dotfiles/ghostty/themes/black-metal-gorgoroth;
     
      # i3 configuration files
      ".config/i3/config".source = ../../dotfiles/i3/config;
      ".config/i3status/config".source = ../../dotfiles/i3status/config;
      
      # Set wallpaper for i3
      ".config/wallpaper.png".source = ../../wallpapers/touch.png;
    };
  };

# Program configurations
  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      history = {
        share = true;
        size = 10000;
        save = 10000;
        ignoreDups = true;
        extended = true;
      };

      initExtraFirst = ''
        autoload -U compinit
        compinit
        eval "$(carapace zsh)"
        eval "$(zoxide init zsh)"
        eval "$(starship init zsh)"

        source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

        bindkey -v
        export KEYTIMEOUT=1
        export GOOGLE_CLOUD_PROJECT="code-408211"
        '';

      shellAliases = {
        rm = "rip";
        lg = "lazygit";
        zed = "zeditor";
        gs = "git status";
        ga = "git add .";
        gc = "git commit -a -m";
        gp = "git push";
        gl = "git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --branches --all";
        v = "nvim";
        vi = "nvim";
        ls = "ls --color=auto";
        ll = "ls -la";
        la = "ls -a";
      };
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    ghostty = {
      enable = true;
      installBatSyntax = true;
      installVimSyntax = true;
      enableZshIntegration = true;
      settings = {
        theme = "black-metal-gorgoroth";
        font-size = 12;
        font-family = "JetBrainsMono Nerd Font Mono";
        shell-integration-features = "sudo";
      };
    };

    home-manager.enable = true;
  };
}
