{ config, pkgs, inputs, ...}:
{
  users.users.denis = { isNormalUser = true;
    password = "1423";
    extraGroups = [ "wheel" "networkmanager" "docker" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      # Apps
      ticktick # For task managment
      zed-editor
      neovim
      wireguard-tools
      obsidian
      gimp
      beeper

      # Shell stuff
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
      zsh # shell
      tree # getter ls tool
      home-manager # manage dotfiles
      nodejs
      go # go compiler and
      git # version controll

    ];
    shell = pkgs.zsh;
  };


}
