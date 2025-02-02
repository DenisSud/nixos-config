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
            dive
            podman-tui
            docker-compose
            fabric-ai
            ripgrep
            kaggle
            lazygit
            git-lfs
            zoxide
            harper
            rip2
            bat
            tor

# Shell utilities
            xclip
            carapace
            pandoc
            nmap
            tree
        ];

# Dotfiles
        file = {
            ".config/nushell/config.nu".source = ../../dotfiles/nushell/config.nu;
            ".config/nushell/env.nu".source = ../../dotfiles/nushell/env.nu;
            ".config/starship.toml".source = ../../dotfiles/starship.toml;
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
                font-size = 13;
            };
        };

        neovim = {
            enable = true;
            defaultEditor = true;
            viAlias = true;
            vimAlias = true;

# Neovim plugins to install
            plugins = with pkgs.vimPlugins; [
                plenary-nvim
                    telescope-nvim
                    mini-nvim
                    render-markdown-nvim
                    avante-nvim
                    dressing-nvim
                    nui-nvim
                    supermaven-nvim
                ];

# Lua-based pluin configuration
            extraLuaConfig = ''
                -- Clipboard settings
                vim.o.clipboard = "unnamedplus"

                -- Enable line numbers and relative numbers
                vim.wo.number = true
                vim.wo.relativenumber = true

                -- Set tab and indentation settings
                vim.o.tabstop = 4
                vim.o.shiftwidth = 4
                vim.o.expandtab = true
                vim.o.smartindent = true
                vim.o.laststatus = 3

                -- Case handling and split behavior
                vim.o.ignorecase = true
                vim.o.smartcase = true
                vim.o.splitbelow = true
                vim.o.splitright = true

                -- Key mappings
                vim.api.nvim_set_keymap('n', '<C-s>', ':w<CR>', { noremap = true, silent = true })
                vim.api.nvim_set_keymap('n', 'j', 'gj', { noremap = true })
                vim.api.nvim_set_keymap('n', 'k', 'gk', { noremap = true })

                -- Leader key and custom key mappings for Telescope
                vim.g.mapleader = " "

                vim.api.nvim_set_keymap('n', '<Leader>ff', ':Telescope find_files<CR>', { noremap = true, silent = true })
                vim.api.nvim_set_keymap('n', '<Leader>fg', ':Telescope live_grep<CR>', { noremap = true, silent = true })
                vim.api.nvim_set_keymap('n', '<Leader>fb', ':Telescope buffers<CR>', { noremap = true, silent = true })
                vim.api.nvim_set_keymap('n', '<Leader>fh', ':Telescope help_tags<CR>', { noremap = true, silent = true })

                -- Autocommands
                vim.api.nvim_create_autocmd("TextYankPost", {
                    pattern = "*",
                    callback = function()
                        vim.highlight.on_yank({ timeout = 200 })
                    end,
                })

                vim.api.nvim_create_autocmd("BufEnter", {
                    pattern = "*",
                    callback = function()
                        vim.opt.formatoptions:remove("c")
                    end,
                })

                require('plenary')
                require('telescope').setup{
                    defaults = {
                        file_ignore_patterns = {"node_modules", ".git"},
                    }
                }
                require("supermaven-nvim").setup({
                    keymaps = {
                        accept_suggestion = "<Tab>",
                        clear_suggestion = "<C-]>",
                        accept_word = "<C-j>",
                    },
                    ignore_filetypes = { cpp = true }, -- or { "cpp", }
                    color = {
                        suggestion_color = "#ffffff",
                        cterm = 244,
                    },
                    log_level = "off", -- set to "off" to disable logging completely
                    disable_inline_completion = false, -- disables inline completion for use with cmp
                    disable_keymaps = false, -- disables built in keymaps for more manual control
                    condition = function()
                        return false
                    end -- condition to check for stopping supermaven, `true` means to stop supermaven when the condition is true.
                })

                require('mini.pairs').setup()
                require('mini.deps').setup()
                require('mini.animate').setup()
                require('mini.statusline').setup()
                require('mini.tabline').setup()
                require('mini.pick').setup()
                require('mini.icons').setup()
                require('mini.comment').setup()
                require('mini.surround').setup()
                require('mini.jump').setup()
                require('mini.completion').setup()
                '';
        };

        home-manager.enable = true;
    };
                            }
