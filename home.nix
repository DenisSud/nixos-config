{ config, pkgs, ... }:
{

  home.username = "denis";
  home.homeDirectory = "/home/denis";

  programs = {

    firefox = {
      enable = false;
      enableGnomeExtensions = true;
      profiles.default = {
        isDefault = true;
        user = "sudakov.denis.2007@gmail.com";
        id = 0;
        settings = {
          "layout.css.backdrop-filter.enabled" = true;
          "layout.css.backdrop-filter.quality" = 3;
          "layout.css.backdrop-filter.radius" = 20;
          "layout.css.backdrop-filter.amount" = "0.8";
        };
      };
    };

    home-manager.enable = true;

    neovim = {
      enable = false;

      defaultEditor = true;

      viAlias = true;
      vimAlias = true;

      extraLuaConfig = builtins.readFile ./modules/vim/init.lua;
    };

    tmux = {
      enable = true;
      extraConfig = ''
        # vim style tmux config

				# remap prefix from 'C-b' to 'C-a'
				unbind C-b
				set-option -g prefix C-a
				bind-key C-a send-prefix


        # mouse behavior
        set -g mouse on

        bind-key : command-prompt

        bind-key n next-window
        bind-key N previous-window

        # use vim-like keys for splits and windows
        bind-key v split-window -h
        bind-key s split-window -v
        bind-key h select-pane -L
        bind-key j select-pane -D
        bind-key k select-pane -U
        bind-key l select-pane -R
      '';
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    yazi = {
      enable = true;
      enableZshIntegration = true;
    };

    wezterm = {
      enable = true;
    };

    lazygit = {
      enable = true;
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    thefuck = {
      enable = true;
    };

    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      shellAliases = {
      	lg = '' lazygit '';
        ld = '' lazydocker'';
        lt = '' tree -L 5'';
        cl = "clear";
        pbcopy='' xclip -selection clipboard '';
        pbpaste='' xclip -selection clipboard -o '';
        gl='' git log --pretty=format:'%h %ad | %s%d [%an]' --graph --date=short '';
        gs='' git status '';
      };

      oh-my-zsh = {
        enable = true;
        plugins = [ "git" "fzf" ];
        theme = "minimal";
      };

    };

    btop = {
      enable = true;
    };

  };

  home.stateVersion = "24.05"; # Please read the comment before changing.

  home.file = {
  };

  home.sessionVariables = {
    OPENAI_BASE_URL="https://api.groq.com/openai/v1";
    DEFAULT_MODEL="llama3-70b-8192";
  };

}
