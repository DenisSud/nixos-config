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
     	 
        vim.g.mapleader = " "
        vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

        vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
        vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

        vim.keymap.set("n", "J", "mzJ`z")
        vim.keymap.set("n", "<C-d>", "<C-d>zz")
        vim.keymap.set("n", "<C-u>", "<C-u>zz")
        vim.keymap.set("n", "n", "nzzzv")
        vim.keymap.set("n", "N", "Nzzzv")
        vim.keymap.set("n", "<leader>zig", "<cmd>LspRestart<cr>")

        vim.keymap.set("n", "<leader>vwm", function()
            require("vim-with-me").StartVimWithMe()
        end)
        vim.keymap.set("n", "<leader>svwm", function()
            require("vim-with-me").StopVimWithMe()
        end)

        -- greatest remap ever
        vim.keymap.set("x", "<leader>p", [["_dP]])

        -- next greatest remap ever : asbjornHaland
        vim.keymap.set({"n", "v"}, "<leader>y", [["+y]])
        vim.keymap.set("n", "<leader>Y", [["+Y]])

        vim.keymap.set({"n", "v"}, "<leader>d", [["_d]])

        -- This is going to get me cancelled
        vim.keymap.set("i", "<C-c>", "<Esc>")

        vim.keymap.set("n", "Q", "<nop>")
        vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
        vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

        vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
        vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
        vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
        vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

        vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
        vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

        vim.keymap.set(
            "n",
            "<leader>ee",
            "oif err != nil {<CR>}<Esc>Oreturn err<Esc>"
        )

        vim.keymap.set("n", "<leader>vpp", "<cmd>e ~/.dotfiles/nvim/.config/nvim/lua/theprimeagen/packer.lua<CR>");
        vim.keymap.set("n", "<leader>mr", "<cmd>CellularAutomaton make_it_rain<CR>");

        vim.keymap.set("n", "<leader><leader>", function()
            vim.cmd("so")
        end)

        vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
        require("nvim-treesitter.configs").setup({
            -- A list of parser names, or "all"
            ensure_installed = {
                "vimdoc", "javascript", "typescript", "c", "lua", "rust",
                "jsdoc", "bash", "python", "golang"
            },

            -- Install parsers synchronously (only applied to `ensure_installed`)
            sync_install = false,

            -- Automatically install missing parsers when entering buffer
            -- Recommendation: set to false if you don"t have `tree-sitter` CLI installed locally
            auto_install = true,

            indent = {
                enable = true
            },

            highlight = {
                -- `false` will disable the whole extension
                enable = true,

                -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
                -- Set this to `true` if you depend on "syntax" being enabled (like for indentation).
                -- Using this option may slow down your editor, and you may see some duplicate highlights.
                -- Instead of true it can also be a list of languages
                additional_vim_regex_highlighting = { "markdown" },
            },
        })

        local treesitter_parser_config = require("nvim-treesitter.parsers").get_parser_configs()
        treesitter_parser_config.templ = {
            install_info = {
                url = "https://github.com/vrischmann/tree-sitter-templ.git",
                files = {"src/parser.c", "src/scanner.c"},
                branch = "master",
            },
        }

        vim.treesitter.language.register("templ", "templ")

      '';
      plugins = with pkgs.vimPlugins; [
        nvim-lspconfig

        comment-nvim
        
        kanagawa-nvim

        harpoon

        telescope-nvim 

        telescope-fzf-native-nvim 

        mason-nvim

	nvim-cmp

        friendly-snippets

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
  
    waybar = {
      enable = false;
      settings = {
        modules = {
          "workspaces" = {
            type = "workspaces";
            format = "{icon}";
            on-scroll-up = "hyprctl dispatch workspace e+1";
            on-scroll-down = "hyprctl dispatch workspace e-1";
          };
          "window" = {
            type = "window";
            format = "{title}";
            max-length = 200;
            separate-outputs = true;
          };
          "cpu" = {
            type = "cpu";
            format = "{usage}%";
          };
          "memory" = {
            type = "memory";
            format = "{usage}%";
          };
          "battery" = {
            type = "battery";
            format = "{percentage}%";
          };
        };
      };
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
