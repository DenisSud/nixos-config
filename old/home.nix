{ config, pkgs, ... }:
{

    home.username = "denis";
    home.homeDirectory = "/home/denis";

    xdg.desktopEntries.andcam = {
        name = "Android Virtual Camera";
        exec = "${pkgs.writeScript "andcam" ''
            ${pkgs.android-tools}/bin/adb start-server
            ${pkgs.scrcpy}/bin/scrcpy --camera-id=0 --video-source=camera --no-audio --v4l2-sink=/dev/video0 -m1024
        ''}";
    };

    home.packages = with pkgs; [
        zed-editor
        speedtest-rs
        nushell
        zoxide
        starship
        zellij
        gitui
        oxker
        tmux
        btop
        fzf
        kitty
    ];

    programs = {

        home-manager.enable = true;
        zellij.enable = true;
        btop.enable = true;
        kitty.enable = true;
        lazygit.enable = true;
        fzf.enable = true;
        gitui.enable = true;

        nushell = {
            enable = true;

            envFile.text = ''
                $env.config = {
                    show_banner: false,
                }
            '';

            environmentVariables = {
                FLAKEDIR = ''~/NixOS'';
            };

            shellAliases = {
                l = "ls -la";
                lt = "tree -L 3";
                v = "nvim";
                lg = "gitui";
                ld = "oxker";
                gs = "git status";
                gl = "git log --oneline --decorate --graph --all";
                ga = "git add";
                gc = "git commit";
                gp = "git push";
                gd = "git diff";
            };
        };

        zoxide = {
            enable = true;
            enableNushellIntegration = true;
            enableBashIntegration = false;
        };

        starship = {
            enable = true;
            enableBashIntegration = true;
            enableNushellIntegration = true;

	    settings = pkgs.lib.importTOML ./starship.toml;

        };
    };

    home.stateVersion = "24.05"; # Please read the comment before changing.

}
