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
        export DEFAULT_MODEL=phi3.5:latest
        export DEFAULT_VENDOR=Ollama
      '';

      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;


      shellAliases = {
        gac = '' git add . && git commit -m "auto commit" && git push '';
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
