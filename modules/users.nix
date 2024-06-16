{config, pkgs, ...}:
{
  
  users.users.denis = {
    isNormalUser = true;
    password = "1423";
    extraGroups = [ "wheel" "networkmanager" "docker" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [

      # Apps
      obsidian # note taking
      ticktick # for task managment
      telegram-desktop
      protonvpn-gui # free vpn
      vscode # IDE
      youtube-music # for music
      wezterm # fast minimal terminal
      mangohud # for monitoring gaming metarics
      bottles
      wineWowPackages.stable
      
      # Shell stuff
      ttyper
      helix
      lazygit
      lazydocker
      eza
      yazi # file manager
      zoxide # better cd (awsome)
      gcc # compiler
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
      home-manager # manage dotfiles
      tree # getter ls tool
      rustup # rust toolkit
      python312 # python
      go # go compiler and
      git # version controll
      ollama # local llms 

    ];
    shell = pkgs.zsh;
  };
  
  programs = {
    zsh.enable = true;
    gamemode.enable = true;
  };
}
