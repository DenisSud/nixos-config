{ config, pkgs, ... }:
{

  home.username = "denis";
  home.homeDirectory = "/home/denis";

  programs = {

    home-manager.enable = true;

    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    lazygit = {
      enable = true;
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    thefuck = {
      enable = true;
    };

    zsh = {

      initExtra = ''
        export WINEPREFIX="$HOME/.wine"
        export DEFAULT_VENDOR=Groq
        export DEFAULT_MODEL=mixtral-8x7b-32768
      '';

      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      shellAliases = {
        vi = '' nvim '';
        vim = '' nvim '';
        gsc = '' git add . && git commit -m "$(git diff | fabric -p summarize_git_changes --model phi3.5:latest)" && git push '';
        gac = '' git commit -am "auto commit" && git push '';
      	lg = '' lazygit '';
        ld = '' lazydocker'';
        lt = '' tree -L 5'';
        cl = "clear";
        pbcopy='' xclip -selection clipboard '';
        pbpaste='' xclip -selection clipboard -o '';
        gl='' git log --pretty=format:'%h %ad | %s%d [%an]' --graph --date=short '';
        gs='' git status '';
      };

      oh-my-zsh = {
        enable = true;
        plugins = [ "git" "fzf" ];
        theme = "minimal";
      };

    };

  };

  home.stateVersion = "24.05"; # Please read the comment before changing.

  home.file = {
  };

}
