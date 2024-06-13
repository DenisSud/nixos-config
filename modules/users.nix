{config, pkgs, ...}:
{
  
  users.users.denis = {
    isNormalUser = true;
    password = "1423";
    extraGroups = [ "wheel" "networkmanager" "docker" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [

      # Apps
      telegram-desktop # messaging
      # obs-studio # screen recording
      obsidian # note taking
      protonvpn-gui # free vpn
      zed-editor # modern IDE
      youtube-music # for music
      kitty

      # Shell stuff
      ranger # file manager
      aria2 # fast downloading utility
      croc # file transfer utility (awsome)
      gnused # stream editor (awdome, google it)
      zsh # shell
      pandoc # file conversion 
      thefuck # command autocorrect
      home-manager # manage dotfiles
      # docker # for containerization
      tree # getter ls tool
      rustup # rust toolkit
      python3 # python
      pipx # for installing packages like fabric
      go # go compiler and
      git # version controll
      gh # github cli interface
      ollama # local llms 
      gnumake # c and cpp compiler

      # LSPs
      nil # for nix
      markdown-oxide # for markdown
      gopls # for go 
      rust-analyzer # for rust
      python311Packages.python-lsp-server # for python

    ];
    shell = pkgs.tmux;
  };
  
  programs = {
    tmux.enable = true;
  };
}
