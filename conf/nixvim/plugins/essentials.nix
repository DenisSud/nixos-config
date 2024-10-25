# plugins/essentials.nix
{ pkgs, ... }: {
  programs.nixvim = {
    plugins = {
      # Comment management
      comment-nvim.enable = true;

      # Auto-pairs
      nvim-autopairs.enable = true;

      # Git integration
      gitsigns = {
        enable = true;
        currentLineBlame = true;
      };

      # File tree
      neo-tree = {
        enable = true;
        closeIfLastWindow = true;
        window.width = 30;
      };

      # Harpoon for quick file navigation
      harpoon = {
        enable = true;
        keymaps = {
          addFile = "<leader>a";
          toggleQuickMenu = "<C-e>";
          navFile = {
            "1" = "<C-h>";
            "2" = "<C-t>";
            "3" = "<C-n>";
            "4" = "<C-s>";
          };
        };
      };

      # Which-key for keybinding help
      which-key = {
        enable = true;
        registrations = {
          "<leader>f".name = " Find";
          "<leader>g".name = " Git";
          "<leader>h".name = "󱡅 Harpoon";
        };
      };

      # Buffer management
      bufferline = {
        enable = true;
        diagnostic = "nvim_lsp";
      };
    };

    # Add keymaps for neo-tree
    keymaps = [
      {
        mode = "n";
        key = "<leader>e";
        action = ":Neotree toggle<CR>";
        options.desc = "Toggle file explorer";
      }
    ];
  };
}
