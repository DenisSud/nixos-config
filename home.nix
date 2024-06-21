{ config, pkgs, ... }:
{

  home.username = "denis";
  home.homeDirectory = "/home/denis";

  programs = {

    home-manager.enable = true;

    alacritty = {
      enable = true;
    };


    neovim = {
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;

      enable = true;
      extraConfig = ''
        ${builtins.readFile /home/denis/nixos/modules/vim/config.vim}
      '';

      plugins = with pkgs.vimPlugins; [
        nvim-lspconfig
        comment-nvim
        harpoon
        telescope-nvim
        telescope-fzf-native-nvim
        mason-nvim
        nvim-cmp
        friendly-snippets
        rust-tools-nvim
        {
          plugin = (nvim-treesitter.withPlugins (p: [
            p.tree-sitter-nix
            p.tree-sitter-rust
            p.tree-sitter-go
            p.tree-sitter-vim
            p.tree-sitter-bash
            p.tree-sitter-lua
            p.tree-sitter-python
            p.tree-sitter-json
          ]));
        }
      ];
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
      enableZshIntegration = true;
    };
  
    lazygit = {
      enable = true;
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    thefuck = {
      enable = false;
      enableZshIntegration = true;
      enableBashIntegration = true;
      enableInstantMode = true;
    };
    
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      shellAliases = {
        l = '' eza -l --icons --git -a '';
        lt = '' eza --tree --level=2 --long --icons --git '';
        cl = "clear";
        pbcopy='' xclip -selection clipboard '';
        pbpaste='' xclip -selection clipboard -o '';
        gl='' git log --pretty=format:'%h %ad | %s%d [%an]' --graph --date=short '';
        gs='' git status '';
        config='' z ~/nixos hx . '';
        rebuild='' cd /home/denis/nixos && git add . && git commit -m "updated conifg" && sudo nixos-rebuild switch --flake ~/nixos#default --impure && git push && cd - '';
      };

      oh-my-zsh = {
        enable = true;
        plugins = [ "git" "thefuck" "fzf" ];
        theme = "minimal";
      };

    };

    helix = {
      enable = true;
      defaultEditor = true;
      extraPackages = [ pkgs.marksman pkgs.nil pkgs.gopls pkgs.python3Packages.python-lsp-server pkgs.rust-analyzer pkgs.dockerfile-language-server-nodejs pkgs.docker-compose-language-service ];
      settings = {

        editor = {
          mouse = false;
          auto-save = true;
          bufferline = "multiple";
          auto-format = true;
          line-number = "relative";
          scrolloff = 6;
        };

        editor.indent-guides = {
          character = "╎";
          render = true;
        };
        editor.statusline = {
          left = [ "mode" "spinner" "diagnostics" ];
          center = [ "file-name" "separator" "version-control" "separator" ];
          right = [ "position" "position-percentage" "total-line-numbers" ];
          mode.normal = "NORMAL";
          mode.insert = "INSERT";
          mode.select = "SELECT";
        };
        keys.normal = {
          esc = ["collapse_selection" "keep_primary_selection"];
          X = "extend_line_above";
        };

        editor.lsp = {
          display-messages = true;
          display-inlay-hints = true;
        };

      };
    };


    tmux = {
      enable = true;
      extraConfig = ''
        # vim style tmux config

        # use C-a, since it's on the home row and easier to hit than C-b
        set-option -g prefix C-a
        unbind-key C-a
        bind-key C-a send-prefix
        set -g base-index 1

        # mouse behavior
        setw -g mouse on

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

        # Enable native Mac OS X copy/paste
        set-option -g default-command "/bin/bash -c 'which reattach-to-user-namespace >/dev/null && exec reattach-to-user-namespace $SHELL -l || exec $SHELL -l'"

      '';
    };
    
    btop = {
      enable = true;
    };

  };

  home.stateVersion = "24.05"; # Please read the comment before changing.
  home.packages = [
  ];

  home.file = {
  };

  home.sessionVariables = {
    OPENAI_BASE_URL="https://api.groq.com/openai/v1";
    DEFAULT_MODEL="llama3-70b-8192";
  };

}
