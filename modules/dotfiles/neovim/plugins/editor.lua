return {
  setup = function()
    -- Telescope setup
    require("telescope").setup{
      defaults = {
        file_ignore_patterns = { "node_modules", ".git" },
        mappings = {
          i = {
            ["<C-j>"] = "move_selection_next",
            ["<C-k>"] = "move_selection_previous",
          }
        }
      }
    }

    -- nvim-tree setup
    require("nvim-tree").setup{
      sort_by = "case_sensitive",
      view = {
        width = 30,
      },
      renderer = {
        group_empty = true,
      },
      filters = {
        dotfiles = true,
      },
    }
  end
}
