{lib, config, pkgs, ... }:

{
	home.username = "denis";
	home.homeDirectory = "/home/denis";

	home.stateVersion = "24.11";

		home.packages = [
		];
	home.file = {
		".config/nushell/config.nu".source = ../../modules/dotfiles/nushell/config.nu;
		".config/nushell/env.nu".source = ../../modules/dotfiles/nushell/env.nu;
		".config/.zoxide.nu".source = ../../modules/dotfiles/nushell/.zoxide.nu;
	};

	home.sessionVariables = {
	};

	programs = {
		kitty = {
			enable = true;
			settings = {
				font_size = 13;
				scrollback_lines = 10000;
				copy_on_select = true;
			};
		};

    zellij.enable = true;
    btop.enable = true;

		neovim = {
			enable = true;
			viAlias = true;
			vimAlias = true;

			plugins = with pkgs.vimPlugins; [
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

				(nvim-treesitter.withPlugins (plugins: with plugins; [
		      tree-sitter-nix
		      tree-sitter-lua
		      tree-sitter-python
		      tree-sitter-rust
		      tree-sitter-typescript
		      tree-sitter-javascript
				]))

				nvim-tree-lua
			];

			extraLuaConfig = lib.fileContents ../../modules/dotfiles/neovim/init.lua;
		};

		home-manager.enable = true;
	};
}
