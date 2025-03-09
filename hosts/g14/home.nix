{ lib, config, pkgs, inputs, ... }:
{
    imports = [
        inputs.stylix.homeManagerModules.stylix
    ];


    stylix = {
        enable = lib.mkDefault true;
        image = lib.mkDefault ../../wallpapers/touch.png;
        polarity = lib.mkDefault "dark";
        base16Scheme = lib.mkDefault "${pkgs.base16-schemes}/share/themes/mountain.yaml";
    };

    home = {
        username = "denis";
        homeDirectory = "/home/denis";
        stateVersion = "24.11";

        packages =  with pkgs;[
            # Development tools
            starship
            docker-compose
            yazi
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
            zsh
            dust
            pandoc
            nmap
            tree
            gnutar

            # For language servers
            lua-language-server # for Lua
            ruff # for Python
            ruff-lsp # for Python
            rust-analyzer
            nil # For Nix language support
            texlab # for LaTeX
            bash-language-server # for Bash
            yaml-language-server # for YAML
        ];

        # Dotfiles
        file = {
            ".zshrc".source = ../../dotfiles/zsh/.zshrc;
            ".config/starship.toml".source = ../../dotfiles/starship.toml;
            ".config/ghostty/themes/mountain-base16".source =
            ../../dotfiles/ghostty/themes/mountain-base16;
            ".config/nvim/lua/plugins".source = ../../dotfiles/nvim/lua/plugins;
            ".config/nvim/init.lua".source = ../../dotfiles/nvim/init.lua;
        };

    };

    # Program configurations
    programs = {
        bat.enable = true;
        btop.enable = true;
        lazygit.enable = true;

        zsh = {
            enable = true;
            enableCompletion = true; # Enable zsh completion system
            history = {
                share = true; # Share history between sessions
            };
            # zshrc = ...  // We will configure this below
            # envExtra = ... // We will configure this below
        };

        ghostty = {
            enable = true;
            installBatSyntax = true;
            enableBashIntegration = true;
            settings = {
                theme = "mountain-base16";
                font-size = 13;
                shell-integration-features = "sudo";
            };
        };

        home-manager.enable = true;
    };

}
