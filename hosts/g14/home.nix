{ lib, config, pkgs, inputs, ... }:
{
    home = {
        username = "denis";
        homeDirectory = "/home/denis";
        stateVersion = "24.11";

        packages = with pkgs; [
            # Development tools
            starship
            gnumeric
            podman-compose
            fabric-ai
            ripgrep
            lazygit
            git-lfs
            zoxide
            harper
            rip2
            bat
            jq
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
            nodejs
            cmake
            python3
            gopls

            # zsh-syntax-highlighting
            zsh-syntax-highlighting
        ];

        # Dotfiles
        file = {
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
            enableCompletion = true;
            autosuggestion.enable = true;
            history = {
                share = true;
                size = 10000;
                save = 10000;
                ignoreDups = true;
                extended = true;
            };

            # Load zsh extra config from file
            initExtraFirst = ''
                autoload -U compinit
                compinit
                eval "$(carapace zsh)"
                eval "$(zoxide init zsh)"
                eval "$(starship init zsh)"

                # Enable zsh-syntax-highlighting
                source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

                # Vi mode with better indication
                bindkey -v
                export KEYTIMEOUT=1
            '';

            shellAliases = {
                rm = "rip";
                zed = "zeditor";
                gs = "git status";
                ga = "git add .";
                gc = "git commit -a -m";
                gp = "git push";
                gl = "git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --branches --all";
                v = "nvim";
                vi = "nvim";
                ls = "ls --color=auto";
                ll = "ls -la";
                la = "ls -a";
            };
        };

        fzf = {
            enable = true;
            enableZshIntegration = true;
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
