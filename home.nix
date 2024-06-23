{ config, pkgs, ... }:
{

  home.username = "denis";
  home.homeDirectory = "/home/denis";

  home.packages = with pkgs; [
  ];

  programs = {

    home-manager.enable = true;

    alacritty = {
      enable = true;
    };


    neovim = {
      enable = true;
      plugins = with pkgs.vimPlugins; [
        nvim-lspconfig
        nvim-cmp
        cmp-nvim-lsp
        cmp-buffer
        cmp-path
        cmp-cmdline
        cmp_luasnip
        luasnip
        telescope-nvim
        mason-nvim
        plenary-nvim
        nvim-treesitter
        neogit
        undotree
        harpoon
      ];

      extraConfig = ''
      -- General settings
vim.o.number = true
vim.o.relativenumber = true
vim.o.hidden = true
vim.o.wrap = false
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true
vim.g.leader = " "

-- Keybindings
vim.api.nvim_set_keymap('n', '<leader>pv', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>u', ':UndotreeToggle<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>gs', ':Neogit<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-f>', '<C-Right>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-b>', '<C-Left>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', 'J', ':m \'>+1<CR>gv=gv', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', 'K', ':m \'<-2<CR>gv=gv', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>y', '"+y', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>Y', '"+Y', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>d', '"_d', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'Q', '<nop>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-c>', ':bd<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>f', ':lua vim.lsp.buf.formatting()<CR>', { noremap = true, silent = true })

vim.api.nvim_set_keymap('i', '<C-k>', '<Plug>luasnip-next-choice', {})
vim.api.nvim_set_keymap('i', '<C-j>', '<Plug>luasnip-prev-choice', {})

-- Telescope keybindings
vim.api.nvim_set_keymap('n', '<leader>ff', ':Telescope find_files<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-p>', ':Telescope git_files<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>fg', ':Telescope live_grep<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>vh', ':Telescope help_tags<CR>', { noremap = true, silent = true })

-- Harpoon keybindings
vim.api.nvim_set_keymap('n', '<leader>a', ':lua require("harpoon.mark").add_file()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-e>', ':lua require("harpoon.ui").toggle_quick_menu()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-h>', ':lua require("harpoon.ui").nav_file(1)<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-t>', ':lua require("harpoon.ui").nav_file(2)<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-n>', ':lua require("harpoon.ui").nav_file(3)<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-s>', ':lua require("harpoon.ui").nav_file(4)<CR>', { noremap = true, silent = true })

-- LSP keybindings
vim.api.nvim_set_keymap('n', 'gd', ':lua vim.lsp.buf.definition()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'K', ':lua vim.lsp.buf.hover()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>vws', ':lua vim.lsp.buf.workspace_symbol()<CR>', { noremap = true, silent = true })

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

  home.file = {
  };

  home.sessionVariables = {
    OPENAI_BASE_URL="https://api.groq.com/openai/v1";
    DEFAULT_MODEL="llama3-70b-8192";
  };

}
