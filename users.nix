{ config, pkgs, inputs, ...}:
{

  users.users.denis = { isNormalUser = true;
    password = "1423";
    extraGroups = [ "wheel" "networkmanager" "docker" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      # Apps
      ticktick # For task managment
      google-chrome
      telegram-desktop # Telegram mesanger
      vscode
      zed-editor
      neovim
      wireguard-tools
      obsidian
      lutris
      wine 
      bottles
      tmux
      python312Packages.ipykernel

      # Shell stuff
      ollama-cuda
      nerdfonts
      git-lfs
      vimPlugins.packer-nvim
      docker # Containerization tool
      lazydocker # TUI for docker
      lazygit # TUI for git
      gcc # C and C++ compiler
      fzf # fuzzy finder (awsome)
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
