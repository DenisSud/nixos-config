{config, pkgs, ...}:
{
  
  users.users.denis = {
    isNormalUser = true;
    password = "1423";
    extraGroups = [ "wheel" "networkmanager" "docker" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [

      # Apps
      obsidian # note taking
      protonvpn-gui # free vpn
      zed-editor # modern IDE
      youtube-music # for music
      gnome.gnome-terminal 

      # Shell stuff
      bat
      jq
      ueberzug
      ranger # file manager
      aria2 # fast downloading utility
      croc # file transfer utility (awsome)
      gnused # stream editor (awdome, google it)
      zsh # shell
      thefuck
      pandoc # file conversion 
      home-manager # manage dotfiles
      tree # getter ls tool
      rustup # rust toolkit
      python3 # python
      pipx # for installing packages like fabric
      go # go compiler and
      git # version controll
      gh # github cli interface
      ollama # local llms 

      # LSPs
      nil # for nix
      markdown-oxide # for markdown
      gopls # for go 
      rust-analyzer # for rust
      python311Packages.python-lsp-server # for python

    ];
    shell = pkgs.zsh;
  };
  
  programs = {
    zsh.enable = true;
  };
}
