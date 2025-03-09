# Existing imports and settings...

# Make sure you have home.stateVersion properly defined
home.stateVersion = "23.11"; # Or whatever version you're using

# For Stylix as a home-manager module:
programs.stylix = {
  enable = true;
  # Your Stylix configuration...
};

# Add avante.nvim to your Neovim configuration
programs.neovim = {
  # Existing neovim config...
  plugins = [
    # Existing plugins...
    {
      plugin = pkgs.vimPlugins.avante-nvim;
      # OR if it's not available in nixpkgs:
      # plugin = pkgs.vimUtils.buildVimPlugin {
      #   name = "avante-nvim";
      #   src = pkgs.fetchFromGitHub {
      #     owner = "avante-nvim-owner"; # Replace with actual owner
      #     repo = "avante-nvim";
      #     rev = "main"; # Or specific version
      #     sha256 = "sha256-..."; # Replace with actual hash
      #   };
      # };
      config = ''
        -- Avante.nvim configuration
        require('avante').setup({
          -- Your configuration options
        })
      '';
    }
  ];
};

# Other configurations... 