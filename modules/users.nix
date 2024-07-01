{ config, pkgs, inputs, ...}:
{
  
  users.users.denis = { isNormalUser = true;
    password = "1423";
    extraGroups = [ "wheel" "networkmanager" "docker" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [

      # Apps
      gnome.gnome-tweaks # Gnome advanced settings
      obsidian # For note taking
      ticktick # For task managment
      telegram-desktop # Telegram mesanger
      zed-editor # IDE
      syncthing # for syncing folders accross devices
			protonvpn-cli_2

      # Shell stuff
			tmux # Utility for terminal tyling, sesions and more
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
      python311 # python
      go # go compiler and
      git # version controll

    ];
    shell = pkgs.zsh;
  };
  
}
