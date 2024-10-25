# plugins/telescope.nix
{
  programs.nixvim = {
    plugins.telescope = {
      enable = true;

      defaults = {
        file_ignore_patterns = [
          "^.git/"
          "^node_modules/"
          "^target/"
        ];

        mappings = {
          i = {
            "<esc>" = {
              __raw = ''
                function(...)
                  return require("telescope.actions").close(...)
                end
              '';
            };
          };
        };
      };

      keymaps = {
        "<leader>ff" = "find_files";
        "<leader>fg" = "live_grep";
        "<leader>fb" = "buffers";
        "<leader>fh" = "help_tags";
        "<leader>fr" = "oldfiles";
      };
    };
  };
}
