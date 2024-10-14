{ config, pkgs, ... }:
{

    home.username = "denis";
    home.homeDirectory = "/home/denis";

    programs = {
        home-manager.enable = true;

        btop = {
            enable = true;
        };

        zoxide = {
            enable = true;
            enableFishIntegration = true;
        };

        lazygit = {
            enable = true;
        };

        fzf = {
            enable = true;
            enableFishIntegration = true;
        };

        thefuck = {
            enable = true;
            enableFishIntegration = true;
        };


        fish = {
            enable = true;

            shellAliases = {
                iv = '' nvim '';
                vi = "nvim";
                vim = "nvim";
                gac = '' git commit -am "auto commit" && git push '';
                lt = '' tree -L 5'';
                pbcopy='' xclip -selection clipboard ''; pbpaste='' xclip -selection clipboard -o '';
                gl='' git log --pretty=format:'%h %ad | %s%d [%an]' --graph --date=short '';
                gs='' git status '';
            };

        };

        starship = {
            enable = true;
            settings = {

                format = ''
                    $directory$git_branch$git_status$docker_context$fill$rust$python$golang$nix_shell$lua
                    $custom$character
                '';

                directory = {
                    style = "blue";
                };

                character = {
                    success_symbol = "[>](green)";
                    error_symbol = "[>](red)";
                    vimcmd_symbol = "[<](green)";
                    vimcmd_replace_one_symbol = "[<](purple)";
                    vimcmd_replace_symbol = "[<](purple)";
                    vimcmd_visual_symbol = "[<](yellow)";
                };

                git_branch = {
                    symbol = "";
                    style = "dimmed green";
                };

                git_status = {
                    format = "[$all_status]($style)";
                    style = "dimmed yellow";
                };

                docker_context = {
                    symbol = "󰡨 ";
                    style = "blue";
                    format = "[$symbol($context )]($style)";
                };

                nix_shell = {
                    symbol = "󱄅 ";
                    style = "blue";
                    format = "[$symbol($state )]($style)";
                };

                # Add a custom module to show a different symbol for root
                custom.root = {
                    when = "test $USER = root";
                    symbol = "#";
                    style = "red bold";
                    format = "[$symbol]($style)";
                };
            };
        };

    };

    home.stateVersion = "24.05"; # Please read the comment before changing.

    home.file = {
    };

}
