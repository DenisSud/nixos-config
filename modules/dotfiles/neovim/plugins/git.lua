return {
  setup = function()
    require("gitsigns").setup{
      on_attach = function(bufnr)
        if vim.api.nvim_buf_get_name(bufnr):match('%.ipynb$') then
          return false
        end
        -- Default gitsigns setup
        local gs = package.loaded.gitsigns
        vim.keymap.set('n', '<leader>hp', gs.preview_hunk, { buffer = bufnr, desc = "Preview git hunk" })
        vim.keymap.set('n', '<leader>hb', gs.blame_line, { buffer = bufnr, desc = "Blame line" })
      end,
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
      },
    }
  end
}
