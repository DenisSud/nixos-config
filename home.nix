{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "denis";
  home.homeDirectory = "/home/denis";

  programs = {

    # Let Home Manager install and manage itself.
    home-manager.enable = true;

    gnome-terminal = {
      enable = true;
      showMenubar = false;
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
      tmux.enableShellIntegration = true;
    };
    
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      envExtra = "export OPENAI_BASE_URL=https://api.groq.com/openai/v1/";      

      shellAliases = {
        ll = "ls -l";
        pbcopy='' xclip -selection clipboard '';
        pbpaste='' xclip -selection clipboard -o '';
        gl='' git log --pretty=format:'%h %ad | %s%d [%an]' --graph --date=short '';
        gs='' git status '';
        config='' hx ~/nixos '';
        rebuild='' cd /home/denis/nixos && git add . && git commit -m "updated conifg" && sudo nixos-rebuild switch --flake ~/nixos#default --impure && git push && cd - '';
      };

      zplug = {
        enable = true;
        plugins = [
          { name = "zsh-users/zsh-autosuggestions"; } # Simple plugin installation
        ];
      };

      oh-my-zsh = {
        enable = true;
        plugins = [ "git" "thefuck" "fzf" ];
        theme = "minimal";
      };

    };

    kitty = {
      enable = true;
      # environment = {
      # };
      shellIntegration.enableZshIntegration = true;
      settings = {
        confirm_os_window_close = -1;
      };
    };   

    helix = {
      enable = true;
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

        # Easy config reload
        bind-key R source-file ~/.tmux.conf \; display-message "tmux.conf reloaded."

        # vi is good
        setw -g mode-keys vi

        # mouse behavior
        setw -g mouse on

        bind-key : command-prompt
        bind-key r refresh-client
        bind-key L clear-history

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

        bind-key [ copy-mode
        bind-key ] paste-buffer

        # Setup 'v' to begin selection as in Vim
        bind-key -T copy-mode-vi v send -X begin-selection
        bind-key -T copy-mode-vi y send -X copy-pipe-and-cancel "reattach-to-user-namespace pbcopy"

        # Update default binding of `Enter` to also use copy-pipe
        unbind -T copy-mode-vi Enter
        bind-key -T copy-mode-vi Enter send -X copy-pipe-and-cancel "reattach-to-user-namespace pbcopy"

        # Status Bar
        set-option -g status-interval 1

        set-option -g pane-active-border-style fg=yellow
        set-option -g pane-border-style fg=cyan

        # Enable native Mac OS X copy/paste
        # set-option -g default-command "/bin/bash -c 'which reattach-to-user-namespace >/dev/null && exec reattach-to-user-namespace $SHELL -l || exec $SHELL -l'"

        # Allow the arrow key to be used immediately after changing windows
        set-option -g repeat-time 0

      '';
    };
    
    btop = {
      enable = true;
    };

    ranger = {
      enable = true;
      extraConfig = ''
        set preview_images_method kitty
        set preview_images true
      '';
    };

  };

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/denis/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

}
