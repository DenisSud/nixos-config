{lib, config, pkgs, ... }:

{
    home.username = "denis";
    home.homeDirectory = "/home/denis";

    home.stateVersion = "24.11";

    home.file = {
        ".config/nushell/config.nu".source = ../../dotfiles/nushell/config.nu;
        ".config/nushell/env.nu".source = ../../dotfiles/nushell/env.nu;
        ".config/starship.toml".source = ../../dotfiles/starship.toml;
        ".config/zed/settings.json".source = ../../dotfiles/zed/settings.json;
    };

    programs = {

        btop.enable = true;
        lazygit.enable = true;

        ghostty = {
            enable = true;
            installBatSyntax = true;
            enableBashIntegration = true;
            settings = {
                theme = "vesper";
            };
        };

        helix = {
          enable = true;   
          settings = {
            editor = {
              line-number = "relative";
              lsp.display-messages = true;
            };
            keys.normal = {
              space.w = ":w";
              space.q = ":q";
              esc = [ "collapse_selection" "keep_primary_selection" ];
              "C-g" = [":new" ":insert-output lazygit" ":buffer-close!" ":redraw"];
            };
          };
        };

        home-manager.enable = true;
    };
}
