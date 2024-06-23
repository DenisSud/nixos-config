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
           
      # Shell stuff
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
