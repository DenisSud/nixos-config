{ lib, config, pkgs, inputs, ... }:
{
  home = {
    username = "denis";
    homeDirectory = "/home/denis";
    stateVersion = "25.05";

# Dotfiles
    file = {
      # Desktop entry for AppImage
      ".local/share/applications/my-app.desktop".text = ''
        [Desktop Entry]
        Version=1.0
        Type=Application
        Name=Helium
        Comment=The Helium Browser
        Exec=appimage-run /home/denis/Helium.AppImage
        Icon=/home/denis/Pictures/Helium-icon.png
        Categories=Utility;
        Terminal=false
        StartupWMClass=my-appimage
      '';
      ".config/nvim".source = ../dotfiles/nvim; # Points to your `dotfiles/nvim` directory
      ".config/starship.toml".source = ../dotfiles/starship.toml;
    };

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      NIXOS_OZONE_WL = "1";
    };
  };

# Program configurations
  programs = {

    btop = {
      package = pkgs.btop-cuda;
      enable = true;
    };

    fzf = {
      enable = true;
      enableFishIntegration = true;
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    atuin = {
      enable = true;
      settings = {
        auto_sync = true;
        search_mode = "fuzzy";
      };
    };

    fish = {
      enable = true;
      interactiveShellInit = ''
        # starship prompt
        if type -q starship
          starship init fish | source
        end

        # zoxide
        if type -q zoxide
          zoxide init fish | source
        end

        # atuin
        if type -q atuin
          atuin init fish | source
        end

        alias v="nvim"
        alias cl="clear"
        
        # Terminal productivity
        alias ls='eza'
        alias ll='eza -lbF --git'
        alias la='eza -lbhHigUmuSa --git'
        alias lt='eza --tree --level=2'
        
        # fzf integration with fd
        set -gx FZF_DEFAULT_COMMAND 'fd --type f'
        set -gx FZF_CTRL_T_COMMAND 'fd --type f'
        set -gx FZF_ALT_C_COMMAND 'fd --type d'
      '';
    };

    ghostty = {
      enable = true;
      installBatSyntax = true;
      installVimSyntax = true;
      enableFishIntegration = true;
      settings = {
        theme = "dark:Black Metal,light:Alabaster";
        font-size = 12;
        font-family = "JetBrainsMono Nerd Font Mono";
        shell-integration-features = "sudo";
        keybind = [
          "ctrl+h=goto_split:left"
          "ctrl+l=goto_split:right"
          "ctrl+j=goto_split:down"
          "ctrl+k=goto_split:up"
        ];
      };

    };

    home-manager.enable = true;
  };

  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    config = {
      modifier = "Mod4";
      terminal = "ghostty";
      startup = [
        { command = "waybar"; always = true; }
        { command = "mako"; always = true; }
        { command = "nm-applet --indicator"; always = true; }
        { command = "blueman-applet"; always = true; }
      ];
      keybindings = {
        "$mod+Return" = "exec ghostty";
        "$mod+d" = "exec wofi --show drun";
        "$mod+Shift+e" = "exec swaynag -t warning -m 'Exit sway?' -B 'Yes' 'swaymsg exit'";
        "$mod+Shift+s" = "exec grim -g \"$(slurp)\" - | wl-copy";
        "$mod+Shift+f" = "exec thunar";
        "$mod+Shift+q" = "kill";
        "$mod+Shift+c" = "reload";
        "$mod+f" = "fullscreen toggle";
        "$mod+s" = "layout stacking";
        "$mod+w" = "layout tabbed";
        "$mod+e" = "layout toggle split";
        "$mod+Shift+space" = "floating toggle";
        "$mod+space" = "focus mode_toggle";
        "$mod+a" = "focus parent";
        "Left" = "focus left";
        "Right" = "focus right";
        "Up" = "focus up";
        "Down" = "focus down";
        "$mod+Left" = "move left";
        "$mod+Right" = "move right";
        "$mod+Up" = "move up";
        "$mod+Down" = "move down";
        "$mod+1" = "workspace number 1";
        "$mod+2" = "workspace number 2";
        "$mod+3" = "workspace number 3";
        "$mod+4" = "workspace number 4";
        "$mod+5" = "workspace number 5";
        "$mod+6" = "workspace number 6";
        "$mod+7" = "workspace number 7";
        "$mod+8" = "workspace number 8";
        "$mod+9" = "workspace number 9";
        "$mod+0" = "workspace number 10";
        "$mod+Shift+1" = "move container to workspace number 1";
        "$mod+Shift+2" = "move container to workspace number 2";
        "$mod+Shift+3" = "move container to workspace number 3";
        "$mod+Shift+4" = "move container to workspace number 4";
        "$mod+Shift+5" = "move container to workspace number 5";
        "$mod+Shift+6" = "move container to workspace number 6";
        "$mod+Shift+7" = "move container to workspace number 7";
        "$mod+Shift+8" = "move container to workspace number 8";
        "$mod+Shift+9" = "move container to workspace number 9";
        "$mod+Shift+0" = "move container to workspace number 10";
      };
    };
  };

  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        modules-left = [ "sway/workspaces" "sway/mode" "sway/window" ];
        modules-center = [ "clock" ];
        modules-right = [ "tray" "pulseaudio" "network" "cpu" "memory" ];
      };
    };
  };

  home.packages = with pkgs; [
    fd
    eza
    waybar
    wofi
    mako
    swaylock
    swayidle
    thunar
    networkmanagerapplet
    blueman
    grim
    slurp
    wl-clipboard
    brightnessctl
    pavucontrol
  ];
}
