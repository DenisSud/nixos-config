{ config, pkgs, inputs, ...}:
{
  
  users.users.denis = { isNormalUser = true;
    password = "1423";
    extraGroups = [ "wheel" "networkmanager" "docker" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [

      # Apps
      gnome.gnome-tweaks
      obsidian # note taking
      ticktick # for task managment
      telegram-desktop
      zed-editor# IDE
      youtube-music # for music
      mozwire

      # Shell stuff
      ripgrep
      gcc
      fzf
      eza
      yazi # file manager
      zoxide # better cd (awsome)
      bat # file viewer
      jq # for working with json
      yq # for working with yaml
      ripgrep # for nvim
      aria2 # fast downloading utility
      croc # file transfer utility (awsome)
      gnused # stream editor (awdome, google it)
      zsh # shell
      thefuck
      pandoc # file conversion 
      tree # getter ls tool
      home-manager # manage dotfiles
      rustup # rust toolkit
      python311 # python
      python312Packages.ptpython
      python312Packages.jupyter-core
      pipx
      go # go compiler and
      git # version controll
      ollama # local llms 

    ];
    shell = pkgs.zsh;
  };
  
}
