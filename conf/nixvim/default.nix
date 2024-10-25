# default.nix
{
  imports = [
    ./plugins/essentials.nix
    ./plugins/lsp.nix
    ./plugins/telescope.nix
    ./plugins/treesitter.nix
  ];

  programs.nixvim = {
    enable = true;

    globals.mapleader = " "; # Use space as leader key

    options = {
      number = true;
      relativenumber = true;
      shiftwidth = 2;
      expandtab = true;
      tabstop = 2;
      softtabstop = 2;
      clipboard = "unnamedplus";
      ignorecase = true;
      smartcase = true;
      termguicolors = true;
    };

    # Basic keymaps
    keymaps = [
      {
        mode = "n";
        key = "<leader>w";
        action = ":w<CR>";
        options.desc = "Save file";
      }
      {
        mode = "n";
        key = "<leader>q";
        action = ":q<CR>";
        options.desc = "Quit";
      }
      {
        mode = "n";
        key = "<C-h>";
        action = "<C-w>h";
        options.desc = "Navigate left";
      }
      {
        mode = "n";
        key = "<C-j>";
        action = "<C-w>j";
        options.desc = "Navigate down";
      }
      {
        mode = "n";
        key = "<C-k>";
        action = "<C-w>k";
        options.desc = "Navigate up";
      }
      {
        mode = "n";
        key = "<C-l>";
        action = "<C-w>l";
        options.desc = "Navigate right";
      }
    ];
  };
}
