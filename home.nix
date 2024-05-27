{ config, pkgs, lib, ... }:

with lib.hm.wt;

{

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;


  home.username = "denis";
  home.homeDirectory = "/home/denis";
  home.stateVersion = "23.05";



  # basic configuration of git, please change to your own
  programs.git = {
    enable = true;
    lfs.enable = true
    userName = "DenisSud";
    userEmail = "sudakov.denis.2007@gmail.com";
    extraConfig = {
      safe = {
        directory = "/etc/nixos";
      };
    };

  };


  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
    };

    initExtra = ''
      (cat /home/denis/.cache/wal/sequences &)
      eval "$(starship init zsh)"
    '';
  };

  dconf.settings = {

    "org/gnome/desktop/peripherals/touchpad" = {
      two-finger-scrolling-enabled = true;
    };

  };




}
