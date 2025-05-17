return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"

    end,
  },
  
  -- my plugins
  { 'echasnovski/mini.nvim', version = false }, -- Nice collection of small plugins
  {
    "supermaven-inc/supermaven-nvim",
    config = function()
      require("supermaven-nvim").setup({})
    end,
  }, -- AI autocomplete
  -- { 'augmentcode/augment.vim' }, -- AI shit

}
