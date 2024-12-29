{lib, config, pkgs, ... }:

{
    home.username = "denis";
    home.homeDirectory = "/home/denis";

    home.stateVersion = "24.11";

    home.file = {
        ".config/nushell/config.nu".source = ../../modules/dotfiles/nushell/config.nu;
        ".config/nushell/env.nu".source = ../../modules/dotfiles/nushell/env.nu;
        ".config/.zoxide.nu".source = ../../modules/dotfiles/nushell/.zoxide.nu;
        ".config/zed/settings.json".source = ../../modules/dotfiles/zed/settings.json;
        ".config/ghostty/config".source = ../../modules/dotfiles/ghostty/config;
    };

    programs = {

        zellij.enable = true;
        btop.enable = true;

        neovim = {
            enable = true;
            viAlias = true;
            vimAlias = true;

            plugins = with pkgs.vimPlugins; [
                jupytext-nvim
                nvim-dap  # for debugging
                nvim-dap-python  # Python debug adapter
                nvim-dap-ui  # UI for debugging
                plenary-nvim
                nui-nvim
                conform-nvim
                nvim-web-devicons
                telescope-nvim
                telescope-fzf-native-nvim
                nvim-cmp
                cmp-buffer
                cmp-path
                cmp-nvim-lsp
                cmp-nvim-lua
                luasnip
                cmp_luasnip
                friendly-snippets
                which-key-nvim

                nvim-lspconfig

                vim-fugitive
                gitsigns-nvim

                tokyonight-nvim
                lualine-nvim
                nvim-tree-lua

                (nvim-treesitter.withPlugins (plugins: with plugins; [
                    tree-sitter-nix
                    tree-sitter-lua
                    tree-sitter-python
                    tree-sitter-rust
                    tree-sitter-typescript
                    tree-sitter-javascript
                ]))

            ];

            extraLuaConfig = ''
                ${builtins.readFile ./modules/dotfiles/neovim/options.lua}
                ${builtins.readFile ./modules/dotfiles/neovim/keymaps.lua}
                ${builtins.readFile ./modules/dotfiles/neovim/plugins/init.lua}
            '';        
        };

        home-manager.enable = true;
    };
}
