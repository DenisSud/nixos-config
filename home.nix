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
            enableZshIntegration = true;
            enableBashIntegration = true; # Enable zoxide for Bash
        };

        lazygit = {
            enable = true;
        };

        fzf = {
            enable = true;
            enableZshIntegration = true;
            enableBashIntegration = true; # Enable fzf for Bash
        };

        thefuck = {
            enable = true;
            enableBashIntegration = true; # Enable thefuck for Bash
        };

        zsh = {

            initExtra = ''
                export DEFAULT_VENDOR=Ollama
                export DEFAULT_MODEL=llama3.2:latest
            '';

            enable = true;
            enableCompletion = true;
            autosuggestion.enable = true;
            syntaxHighlighting.enable = true;

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

        bash = {

            enable = true; # Enable Bash

            initExtra = ''
                  # Set a minimal prompt style
                  PS1='@\h:\w\$ '
                  export PS1
            '';

            # Enable programmable completion
            shellAliases = {
                vi = "nvim";
                vim = "nvim";
                gsc = "git add . && git commit -m \"$(git diff | fabric -p summarize_git_changes --model phi3.5:latest)\" && git push";
                gac = "git commit -am \"auto commit\" && git push";
                lg = "lazygit";
                ld = "lazydocker";
                lt = "tree -L 5";
                cl = "clear";
                pbcopy = "xclip -selection clipboard";
                pbpaste = "xclip -selection clipboard -o";
                gl = "git log --pretty=format:'%h %ad | %s%d [%an]' --graph --date=short";
                gs = "git status";
            };

        };

    };

    home.stateVersion = "24.05"; # Please read the comment before changing.

    home.file = {
    };

}
