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
        neovim
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
            environmentVariables = {
                FLAKE = "/home/denis/NixOS";
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
            enableFishIntegration = true;
            enableNushellIntegration = true;

            settings = {
                add_newline = false;
                format = ''$directory$character'';
                palette = "catppuccin_mocha";
                right_format = ''all'';
                command_timeout = 1000;

                # Directory substitutions
                directory = {
                    substitutions = {
                        "~/tests/starship-custom" = "work-project";
                    };
                };

                # Git branch formatting
                git_branch = {
                    format = "[$symbol$branch(:$remote_branch)]($style)";
                };

                # AWS configuration
                aws = {
                    format = ''[$symbol(profile: "$profile" )(\(region: $region\) )]($style)'';
                    disabled = false;
                    style = "bold blue";
                    symbol = " ";
                };

                # Golang configuration
                golang = {
                    format = "[ ](bold cyan)";
                };

                # Kubernetes configuration
                kubernetes = {
                    symbol = "☸ ";
                    disabled = true;
                    detect_files = [ "Dockerfile" ];
                    format = "[$symbol$context( \($namespace\))]($style) ";
                    contexts = [
                    {
                        context_pattern = "arn:aws:eks:us-west-2:577926974532:cluster/zd-pvc-omer";
                        style = "green";
                        context_alias = "omerxx";
                        symbol = " ";
                    }
                    ];
                };

                # Docker context configuration
                docker_context = {
                    disabled = true;
                };

                # Catppuccin mocha palette colors
                palettes = {
                    catppuccin_mocha = {
                        rosewater = "#f5e0dc";
                        flamingo = "#f2cdcd";
                        pink = "#f5c2e7";
                        mauve = "#cba6f7";
                        red = "#f38ba8";
                        maroon = "#eba0ac";
                        peach = "#fab387";
                        yellow = "#f9e2af";
                        green = "#a6e3a1";
                        teal = "#94e2d5";
                        sky = "#89dceb";
                        sapphire = "#74c7ec";
                        blue = "#89b4fa";
                        lavender = "#b4befe";
                        text = "#cdd6f4";
                        subtext1 = "#bac2de";
                        subtext0 = "#a6adc8";
                        overlay2 = "#9399b2";
                        overlay1 = "#7f849c";
                        overlay0 = "#6c7086";
                        surface2 = "#585b70";
                        surface1 = "#45475a";
                        surface0 = "#313244";
                        base = "#1e1e2e";
                        mantle = "#181825";
                        crust = "#11111b";
                    };
                };
            };
        };
    };

    home.stateVersion = "24.05"; # Please read the comment before changing.

}
