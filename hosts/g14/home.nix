{lib, config, pkgs, ... }:

{
    home.username = "denis";
    home.homeDirectory = "/home/denis";

    home.stateVersion = "24.11";

    home.file = {
        ".config/nushell/config.nu".source = ../../dotfiles/nushell/config.nu;
        ".config/nushell/env.nu".source = ../../dotfiles/nushell/env.nu;
        ".config/starship.toml".source = ../../dotfiles/starship.toml;
        ".config/zed/settings.json".source = ../../dotfiles/zed/settings.json;
    };

    programs = {

        btop.enable = true;

        ghostty = {
            enable = true;
            installBatSyntax = true;
            installVimSyntax = true;
            enableBashIntegration = true;
            settings = {
                theme = "vesper";
            };
        };

        neovim = {
            enable = true;
            viAlias = true;
            vimAlias = true;

            plugins = with pkgs.vimPlugins; [
                jupytext-nvim
                mason-nvim
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
	    ${builtins.readFile ../../dotfiles/neovim/options.lua}
	    ${builtins.readFile ../../dotfiles/neovim/keymaps.lua}
	    ${builtins.readFile ../../dotfiles/neovim/plugins/init.lua}
	    '';
      };

        home-manager.enable = true;
    };
}
