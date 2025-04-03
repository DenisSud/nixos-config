return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    }
  },
  {
    "williamboman/mason.nvim",
    config = true
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-path",        -- File path completions
      "hrsh7th/cmp-buffer",      -- Buffer word completions
      "hrsh7th/cmp-cmdline",     -- Command line completions
    },
    config = function()
      local cmp = require('cmp')
      cmp.setup({
        sources = {
          { name = 'nvim_lsp' },  -- LSP completions
          { name = 'path' },      -- File paths
          { name = 'buffer' },    -- Current buffer
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
        })
      })
    end
  }
}
