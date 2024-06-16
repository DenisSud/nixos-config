{ config, pkgs, ... }:
{
  home.username = "denis";
  home.homeDirectory = "/home/denis";

  programs = {

    home-manager.enable = true;

    neovim = {
      enable = true;
      # Add Telescope plugin
      plugins = with pkgs; [
        ripgrep
        telescope
        mason
        harpoon
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
        v = '' vim '';
        vf = '' vim $(fzf) '';
        l = '' eza -l --icons --git -a '';
        lt = '' eza --tree --level=2 --long --icons --git '';
        cl = "clear";
        pbcopy='' xclip -selection clipboard '';
        pbpaste='' xclip -selection clipboard -o '';
        gl='' git log --pretty=format:'%h %ad | %s%d [%an]' --graph --date=short '';
        gs='' git status '';
        config='' nvim ~/nixos '';
        rebuild='' cd /home/denis/nixos && git add . && git commit -m "updated conifg" && sudo nixos-rebuild switch --flake ~/nixos#default --impure && git push && cd - '';
      };

      oh-my-zsh = {
        enable = true;
        plugins = [ "git" "thefuck" "fzf" ];
        theme = "minimal";
      };

    };

    kitty = {
      enable = false;
      # shellIntegration.enableZshIntegration = true;
      settings = {
        confirm_os_window_close = 0;
      };
    };   

    helix = {
      enable = false;
      defaultEditor = true;
      extraPackages = [ pkgs.marksman pkgs.nil pkgs.gopls pkgs.python3Packages.python-lsp-server pkgs.rust-analyzer ];
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
      clock24 = true;
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
        bind-key enter next-layout

        # use vim-like keys for splits and windows
        bind-key v split-window -h
        bind-key s split-window -v
        bind-key h select-pane -L
        bind-key j select-pane -D
        bind-key k select-pane -U
        bind-key l select-pane -R

        # smart pane switching with awareness of vim splits
        bind -n C-h run "(tmux display-message -p '#{pane_current_command}' | grep -iqE '(^|\/)vim$' && tmux send-keys C-h) || tmux select-pane -L"
        bind -n C-j run "(tmux display-message -p '#{pane_current_command}' | grep -iqE '(^|\/)vim$' && tmux send-keys C-j) || tmux select-pane -D"
        bind -n C-k run "(tmux display-message -p '#{pane_current_command}' | grep -iqE '(^|\/)vim$' && tmux send-keys C-k) || tmux select-pane -U"
        bind -n C-l run "(tmux display-message -p '#{pane_current_command}' | grep -iqE '(^|\/)vim$' && tmux send-keys C-l) || tmux select-pane -R"
        bind -n 'C-\' run "(tmux display-message -p '#{pane_current_command}' | grep -iqE '(^|\/)vim$' && tmux send-keys 'C-\\') || tmux select-pane -l"
        bind C-l send-keys 'C-l'

        bind-key C-o rotate-window

        bind-key + select-layout main-horizontal
        bind-key = select-layout main-vertical

        set-window-option -g other-pane-height 25
        set-window-option -g other-pane-width 80
        set-window-option -g display-panes-time 1500
        set-window-option -g window-status-current-style fg=magenta

        bind-key a last-pane
        bind-key q display-panes
        bind-key c new-window
        bind-key t next-window
        bind-key T previous-window

        # Status Bar
        set-option -g status-interval 1

        # Enable native Mac OS X copy/paste
        # set-option -g default-command "/bin/bash -c 'which reattach-to-user-namespace >/dev/null && exec reattach-to-user-namespace $SHELL -l || exec $SHELL -l'"

      '';
    };
    
    btop = {
      enable = true;
    };

    lf = {
      enable = true;
      previewer.source = pkgs.writeShellScript "pv.sh" ''
         #!/bin/sh

         case "$1" in
             *.tar*) tar tf "$1";;
             *.zip) unzip -l "$1";;
             *.rar) unrar l "$1";;
             *.7z) 7z l "$1";;
             *.pdf) pdftotext "$1" -;;
             *) highlight -O ansi "$1" || cat "$1";;
         esac
       '';


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
