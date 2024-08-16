{ config, pkgs, inputs, ...}:
{

  users.users.denis = { isNormalUser = true;
    password = "1423";
    extraGroups = [ "wheel" "networkmanager" "docker" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      # Apps
      ticktick # For task managment
      telegram-desktop # Telegram mesanger
      neovim
      zed-editor
      youtube-music
      obsidian
      lmstudio
      discord

      # Shell stuff
      age
      nerdfonts
      git
      git-lfs
      zellij
      vimPlugins.packer-nvim
      smassh # TUI monkeytype
      docker # Containerization tool
      openai-whisper
      lazydocker # TUI for docker
      lazygit # TUI for git
      gcc # C and C++ compiler
      fzf # fuzzy finder (awsome)
      yazi # file manager
      zoxide # better cd (awsome)
      bat # file viewer
      ripgrep # for nvim
      gnused # stream editor (awdome, google it)
      zsh # shell
      pandoc # file conversion
      tree # getter ls tool
      home-manager # manage dotfiles
      rustup # rust toolkit
      nodejs
      go # go compiler and
      git # version controll

    ];
    shell = pkgs.zsh;
  };


}
