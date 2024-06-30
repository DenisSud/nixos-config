{ config, pkgs, ... }:
{

  home.username = "denis";
  home.homeDirectory = "/home/denis";

  programs = {

    home-manager.enable = true;

    neovim = 
    let 
      toLua = str: "lua <<EOF\n${str}\nEOF\n";
      toLuaFile = file: "lua <<EOF\n${builtins.readFile file}\nEOF\n";
    in
    {
      enable = true;

			defaultEditor = true;

			viAlias = true;
			vimAlias = true;

      plugins = with pkgs.vimPlugins; [

        {
          plugin = nvim-lspconfig;
          # config = toLuaFile ./modules/vim/plugins/lsp.lua ;
        }
        
        {
          plugin = nvim-cmp;
          # config = toLuaFile ./modules/vim/plugins/cmp.lua;
        }

        {
          plugin = telescope-nvim;
          # config = toLua ./modules/vim/plugins/telescope.lua;
        }

        {
          plugin = nvim-treesitter;
          # config = toLua ./modules/vim/plugins/treesitter.lua;
        }

        cmp-nvim-lsp
        luasnip
        mason-nvim
        neogit
        undotree
        harpoon
        (nvim-treesitter.withPlugins (p: [
          p.tree-sitter-nix
          p.tree-sitter-rust
          p.tree-sitter-python
          p.tree-sitter-go
          p.tree-sitter-lua
          p.tree-sitter-json
          p.tree-sitter-bash
          p.tree-sitter-toml
        ]))
      ];

      extraLuaConfig = ''
        ${builtins.readFile ./modules/vim/options.lua}
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
        lt = '' tree -L 5'';
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

    tmux = {
      enable = false;
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

  home.file = {
  };

  home.sessionVariables = {
    OPENAI_BASE_URL="https://api.groq.com/openai/v1";
    DEFAULT_MODEL="llama3-70b-8192";
  };

}
