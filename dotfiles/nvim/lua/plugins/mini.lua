return {
  {
    'echasnovski/mini.nvim',
    version = '*',
    config = function()
      -- Basic configuration (optional but recommended)
      require('mini.basics').setup({
        options = {
          basic = true,  -- Set basic options (vim.opt)
          extra_ui = true, -- Enable extra UI features
          win_borders = 'default' -- Preserve window borders
        }
      })

      -- Configure individual modules
      require('mini.completion').setup({
        lsp_completion = {
          source_func = 'omnifunc',  -- Use LSP as completion source
          auto_setup = true,         -- Auto-configure LSP
        },
        delay = {
          completion = 150,          -- Slightly faster than default
        }
      })
      require('mini.surround').setup()
      require('mini.pairs').setup()
      require('mini.icons').setup()
      require('mini.files').setup()
      require('mini.tabline').setup()
      require('mini.statusline').setup()
      require('mini.clue').setup()
    end
  }
}
