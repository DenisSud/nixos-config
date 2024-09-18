{ config, pkgs, inputs, ...}:
{
  users.users.denis = {
    isNormalUser = true;
    password = "1423";
    extraGroups = [ "wheel" "networkmanager" "docker" ];
    packages = with pkgs; [
      # Apps
      ticktick
      zed-editor
      neovim
      wireguard-tools
      obsidian
      gimp
      beeper

      # Shell stuff
      yt-dlp
      fabric-ai
      jupyter
      texliveMedium
      pandoc
      nerdfonts
      git-lfs
      vimPlugins.packer-nvim
      docker
      lazydocker
      lazygit
      gcc
      fzf
      zoxide
      bat
      ripgrep
      zsh
      tree
      home-manager
      nodejs
      go
      git
    ];
    shell = pkgs.zsh;
  };
}
