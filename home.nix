{ config, pkgs, ... }:
{

    home.username = "denis";
    home.homeDirectory = "/home/denis";

    programs = {

        home-manager.enable = true;

        kitty = {
            enable = true;
            extraConfig = ''
        hide_window_decorations yes
        window_border_width 3
        draw_minimal_borders yes
            '';
        };

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
                pbcopy='' xclip -selection clipboard '';
                pbpaste='' xclip -selection clipboard -o '';
                gl='' git log --pretty=format:'%h %ad | %s%d [%an]' --graph --date=short '';
                gs='' git status '';
            };

            oh-my-zsh = {
                enable = true;
                plugins = [ "git" "fzf" "thefuck" ];
                theme = "minimal";
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
