{ lib, config, pkgs, ... }:
{

  home = {
    username = "denis";
    homeDirectory = "/home/denis";
    stateVersion = "24.11";

    packages =  with pkgs;[
      # Development tools
      starship
      aider-chat
      open-interpreter
      podman-compose
      superfile
      fabric-ai
      ripgrep
      lazygit
      git-lfs
      direnv
      zoxide
      harper
      rip2
      bat
      tor
      gh

      # Shell utilities
      unzip
      zip
      cargo
      xclip
      carapace
      dust
      pandoc
      nmap
      tree
      gnutar

      # For language servers
      lua-language-server
      ruff
      ruff-lsp
      rust-analyzer
      nil               # For Nix language support
      bash-language-server
      yaml-language-server
    ];

    # Dotfiles
    file = {
      ".config/nushell/config.nu".source = ../../dotfiles/nushell/config.nu;
      ".config/nushell/env.nu".source = ../../dotfiles/nushell/env.nu;
      ".config/starship.toml".source = ../../dotfiles/starship.toml;
      ".config/ghostty/themes/mountain-base16".source =
        ../../dotfiles/ghostty/themes/mountain-base16;
      ".config/nvim/lua/plugins".source = ../../dotfiles/nvim/lua/plugins;
      ".config/nvim/init.lua".source = ../../dotfiles/nvim/init.lua;
    };

  };

  # Program configurations
  programs = {
    bat.enable = true;
    btop.enable = true;
    lazygit.enable = true;

    ghostty = {
      enable = true;
      installBatSyntax = true;
      enableBashIntegration = true;
      settings = {
        theme = "mountain-base16";
        font-size = 13;
        shell-integration-features = "sudo";
      };
    };

    home-manager.enable = true;
  };

}
