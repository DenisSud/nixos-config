{ config, pkgs, inputs, ...}:
{

  users.users.denis = { isNormalUser = true;
    password = "1423";
    extraGroups = [ "wheel" "networkmanager" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      # Apps
      ticktick # For task managment
      telegram-desktop # Telegram mesanger
      zed-editor # IDE
      neovim
      youtube-music

      # Shell stuff
      git
      zellij
      vimPlugins.packer-nvim
      smassh # TUI monkeytype
      docker # Containerization tool
      openai-whisper
      lazydocker # TUI for docker
      lazygit # TUI for git
      ripgrep # Grep tool
      gcc # C and C++ compiler
      fzf # fuzzy finder (awsome)
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
      python312 # python
      nodejs
      go # go compiler and
      git # version controll

    ];
    shell = pkgs.zsh;
  };


}
