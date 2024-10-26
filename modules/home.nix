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
        wezterm
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
    		    edit_mode: vi;
    	    '';

            environmentVariables = {
                FLAKEREF = "/home/denis/NixOS/";
            };

            shellAliases = {
                l = "ls -la";
                lt = "tree -L 3";
                v = "nvim";
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
            enableBashIntegration = true;
        };

        zed-editor = {
            enable = true;
            userSettings = {
                base_keymap = "VSCode";
                terminal = {
                    copy_on_select = true;
                    env = {
                        EDITOR = "zed --wait";
                    };
                    dock = "bottom";
                    font_size = 15;
                    shell = {
                        program = "nu";
                    };
                };

                ui_font_size = 16;
                buffer_font_size = 15;
                buffer_font_family = "JetBrainsMono Nerd Font";
                tab_bar.show = true;
                scrollbar.show = "never";
                inlay_hints.enabled = true;
                show_completions_on_input = true;
                show_completions_on_tab = true;
                features.inline_completion_provider = "supermaven";
                notification_panel.dock = "left";
                chat_panel.dock = "left";
                indent_guides.enabled = true;

                theme = {
                    mode = "system";
                    light = "Base16 Da One Ligth";
                    dark = "Base16 Da One Gray";
                };
                show_inline_completions = true;

                vim_mode = true;
                vim = {
                    use_multiline_find = true;
                    use_smartcase_find = true;
                    toggle_relative_line_numbers = true;
                };

                file_types = {
                    Dockerfile = ["Dockerfile" "Dockerfile.*"];
                    JSON = ["json" "jsonc" "*.code-snippets"];
                };

                file_scan_exclusions = [
                "**/.git" "**/.svn" "**/.hg" "**/CVS"
                "**/.DS_Store" "**/Thumbs.db" "**/.classpath"
                "**/.settings" "**/out" "**/dist" "**/.husky"
                "**/.turbo" "**/.vscode-test" "**/.vscode"
                "**/.next" "**/.storybook" "**/.tap" "**/.nyc_output"
                "**/node_modules"
                ];

                project_panel = {
                    button = true;
                    dock = "right";
                    git_status = true;
                };

                outline_panel.dock = "right";

                collaboration_panel.dock = "left";

                centered_layout = {
                    left_padding = 0.15;
                    right_padding = 0.15;
                };

                language_models = {
                    Mistral = {
                        api_url = "https://codestral.mistral.ai/v1/chat/completions";
                    };
                };

                assistant = {
                    default_model = {
                        provider = "zed.dev";
                        model = "claude-3-5-sonnet-20240620";
                    };
                    version = "2";
                };

            };
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
