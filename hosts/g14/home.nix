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
            aider-chat
            open-interpreter
            docker-compose
            fabric-ai
            ripgrep
            lazygit
            git-lfs
            direnv
            zoxide
            harper
            rip2
            bat
            tor
            gh

            # Shell utilities
            unzip
            zip
            cargo
            xclip
            carapace
            pandoc
            nmap
            tree
            gnutar

            # For language servers
            nodejs
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
                theme = "Oxocarbon";
                font-size = 13;
            };
        };

        neovim = {
            enable = true;
            defaultEditor = true;
            viAlias = true;
            vimAlias = true;

            plugins = with pkgs.vimPlugins; [
                lazy-nvim
            ];

            extraLuaConfig = builtins.readFile ../../dotfiles/nvim/init.lua;
        };

        home-manager.enable = true;
    };
}
