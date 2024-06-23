-- Packer setup
vim.cmd [[packadd packer.nvim]]

-- Initialize plugins
require('packer').startup(function()
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- LSP and Completion
  use 'neovim/nvim-lspconfig'
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-cmdline'
  use 'saadparwaiz1/cmp_luasnip'
  use 'L3MON4D3/LuaSnip'

  -- Telescope
  use 'nvim-telescope/telescope.nvim'
  use 'nvim-lua/plenary.nvim'
  use {'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }

  -- Treesitter
  use {'nvim-treesitter/nvim-treesitter', run = ':TSUpdate'}

  -- Neogit
  use 'NeogitOrg/neogit'

  -- File Explorer
  use 'kyazdani42/nvim-tree.lua'

  -- Status Line
  use 'nvim-lualine/lualine.nvim'

  -- Utility Plugins
  use 'mbbill/undotree'
  use 'ThePrimeagen/harpoon'
  use 'tpope/vim-surround'
  use 'tpope/vim-commentary'
  use 'lukas-reineke/indent-blankline.nvim'
  use 'windwp/nvim-autopairs'
  use 'numToStr/Comment.nvim'
end)

-- Keybindings and other configurations
vim.g.mapleader = ' ' -- Set leader key

-- Example keybinding for Telescope
vim.api.nvim_set_keymap('n', '<leader>pf', ":lua require('telescope.builtin').find_files()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>ps', ":lua require('telescope.builtin').grep_string()<CR>", { noremap = true, silent = true })

-- LSP settings
local nvim_lsp = require('lspconfig')

nvim_lsp.pyright.setup{}
nvim_lsp.rust_analyzer.setup{}
nvim_lsp.gopls.setup{}

-- Completion setup
local cmp = require'cmp'
cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = {
    ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
    ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
    ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
    ['<C-y>'] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
    ['<C-e>'] = cmp.mapping({
      i = cmp.mapping.abort(),
      c = cmp.mapping.close(),
    }),
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  },
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  }, {
    { name = 'buffer' },
  })
})
