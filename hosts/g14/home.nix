{ lib, config, pkgs, ... }: {

    nixpkgs.config = {
        allowUnfree = true;  # Add this line
    };

    home = {
        username = "denis";
        homeDirectory = "/home/denis";
        stateVersion = "24.11";

        packages = with pkgs; [
            # Development tools
            starship
            fabric-ai
            zed-editor
            ripgrep
            lazygit
            zoxide
            harper
            rip2
            bat

            # Shell utilities
            carapace
            pandoc
            nmap
            tree

            # Applications
            galaxy-buds-client
            telegram-desktop
            gnome-solanum
            eyedropper
            seahorse
            obsidian
            twingate
            bottles
        ];

        # Dotfiles
        file = {
            ".config/nushell/config.nu".source = ../../dotfiles/nushell/config.nu;
            ".config/nushell/env.nu".source = ../../dotfiles/nushell/env.nu;
            ".config/starship.toml".source = ../../dotfiles/starship.toml;
            ".config/zed/settings.json".source = ../../dotfiles/zed/settings.json;
        };
    };

    # Program configurations
    programs = {
        bat.enable = true;
        btop.enable = true;
        lazygit.enable = true;

        ghostty = {
            enable = true;
            installBatSyntax = true;
            enableBashIntegration = true;
            settings = {
                theme = "vesper";
                font-size = 14;
            };
        };

        neovim = {
            enable = true;
            defaultEditor = true;
            viAlias = true;
            vimAlias = true;
            extraConfig = ''
                " Enable line numbers and relative numbers
                set number
                set relativenumber

                " Set tab and indentation settings
                set tabstop=4
                set shiftwidth=4
                set expandtab
                set smartindent

                " Case handling and split behavior
                set ignorecase
                set smartcase
                set splitbelow
                set splitright

                " Key mappings
                nnoremap <C-s> :w<CR>
                nnoremap j gj
                nnoremap k gk

                " Leader key and custom key mappings for Telescope
                let mapleader = "\<Space>"
                nnoremap <Leader>ff :Telescope find_files<CR>
                nnoremap <Leader>fg :Telescope live_grep<CR>
                nnoremap <Leader>fb :Telescope buffers<CR>
                nnoremap <Leader>fh :Telescope help_tags<CR>

                " Autocommands
                autocmd TextYankPost * silent! lua vim.highlight.on_yank({ timeout = 200 })
                autocmd BufEnter * setlocal formatoptions-=cro
                '';

            # Neovim plugins to install
            plugins = with pkgs.vimPlugins; [
                plenary-nvim
                telescope-nvim
                mini-nvim
            ];

            # Lua-based plugin configuration
            extraLuaConfig = ''
                require('plenary')
                require('telescope').setup{
                    defaults = {
                        file_ignore_patterns = {"node_modules", ".git"},
                    }
                }

            require('mini.pairs').setup()
                require('mini.comment').setup()
                require('mini.surround').setup()
                require('mini.jump').setup()
                require('mini.completion').setup()
                '';
        };

        home-manager.enable = true;
    };
                            }
