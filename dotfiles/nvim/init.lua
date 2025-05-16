-- Neovim Configuration
-- ====================

-- This config is structured into the following sections:
-- 1. Initial Setup
-- 2. Core Settings
-- 3. Plugin Management
-- 4. Keymaps
-- 5. Autocommands

-----------------------
-- === 1. INITIAL SETUP
-----------------------
local vim = vim -- Fix global vim references
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

-----------------------
-- === 2. CORE SETTINGS
-----------------------
-- Editor behavior
vim.o.clipboard = "unnamedplus"
vim.wo.number = true
vim.wo.relativenumber = true
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true
vim.o.smartindent = true
vim.o.laststatus = 3

-- Search settings
vim.o.ignorecase = true
vim.o.smartcase = true

-- Split behavior
vim.o.splitbelow = true
vim.o.splitright = true

-- Leader key
vim.g.mapleader = " "


---------------------------
-- === 3. PLUGIN MANAGEMENT
---------------------------
require("lazy").setup({
  require("plugins.base16_theme"), -- plugins/base16_theme.lua
  require("plugins.terminal"),
  require("plugins.lsp"),          -- Add our new LSP Zero setup
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("nvim-tree").setup {}
    end,
  },
  'echasnovski/mini.nvim',
  'nvim-lua/plenary.nvim',
  "kdheepak/lazygit.nvim",
  'nvim-telescope/telescope.nvim',
  requires = {
    { 'nvim-lua/plenary.nvim' },
    { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
  },
})

-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- optionally enable 24-bit colour
vim.opt.termguicolors = true

-- empty setup using defaults
require("nvim-tree").setup()

-- OR setup with some options
require("nvim-tree").setup({
  sort = {
    sorter = "case_sensitive",
  },
  view = {
    width = 30,
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = true,
  },
})

-- Basic configuration (optional but recommended)
require('mini.basics').setup({
  silent = true,            -- Whether to disable showing non-error feedback
  options = {
    extra_ui = true,        -- Enable extra UI features
    win_borders = 'default' -- Preserve window borders
  },
  mappings = {
    windows = true -- Window navigation with <C-hjkl>, resize with <C-arrow>
  },
  autocommands = {
    relnum_in_visual_mode = true
  }
})

-- Configure individual modules
require('mini.completion').setup({
  lsp_completion = {
    source_func = 'omnifunc', -- Use LSP as completion source
    auto_setup = true,        -- Auto-configure LSP
  },
})

local miniclue = require('mini.clue')
miniclue.setup({
  triggers = {
    -- Leader triggers
    { mode = 'n', keys = '<Leader>' },
    { mode = 'x', keys = '<Leader>' },

    -- Built-in completion
    { mode = 'i', keys = '<C-x>' },

    -- `g` key
    { mode = 'n', keys = 'g' },
    { mode = 'x', keys = 'g' },

    -- Marks
    { mode = 'n', keys = '`' },
    { mode = 'x', keys = "'" },
    { mode = 'x', keys = '`' },

    -- Registers
    { mode = 'n', keys = '"' },
    { mode = 'x', keys = '"' },
    { mode = 'i', keys = '<C-r>' },
    { mode = 'c', keys = '<C-r>' },

    -- Window commands
    { mode = 'n', keys = '<C-w>' },

    -- `z` key
    { mode = 'n', keys = 'z' },
    { mode = 'x', keys = 'z' },
  },

  clues = {
    -- Enhance this by adding descriptions for <Leader> mapping groups
    miniclue.gen_clues.builtin_completion(),
    miniclue.gen_clues.g(),
    miniclue.gen_clues.marks(),
    miniclue.gen_clues.registers(),
    miniclue.gen_clues.windows(),
    miniclue.gen_clues.z(),
  },
})
require('mini.jump2d').setup()
require('mini.operators').setup()
require('mini.notify').setup()
require('mini.map').setup()
require('mini.indentscope').setup()
require('mini.icons').setup()
require('mini.cursorword').setup()
require('mini.starter').setup()
require('mini.ai').setup()
require('mini.surround').setup()
require('mini.pairs').setup()
require('mini.icons').setup()
require('mini.tabline').setup()
require('mini.statusline').setup()
require('mini.git').setup()

-------------------
-- === 4. KEYMAPS
-------------------
-- General keymaps
vim.keymap.set('n', 'j', 'gj', { remap = true })
vim.keymap.set('n', 'k', 'gk', { remap = true })
vim.keymap.set('n', '<Space>', ':w<CR>')

-- Tree-nvim
vim.keymap.set('n', '<leader>e', ':NvimTreeToggle')

-- Telescope keymaps
vim.keymap.set('n', '<leader>ff', require('telescope.builtin').find_files, { desc = 'Find files' })
vim.keymap.set('n', '<leader>fg', require('telescope.builtin').live_grep, { desc = 'Live grep' })
vim.keymap.set('n', '<leader>fj', require('telescope.builtin').grep_string, { desc = 'Grep string' })
vim.keymap.set('n', '<leader>fb', require('telescope.builtin').buffers, { desc = 'Find buffers' })
vim.keymap.set('n', '<leader>fh', require('telescope.builtin').help_tags, { desc = 'Help tags' })
vim.keymap.set('n', '<leader>fs', require('telescope.builtin').lsp_document_symbols, { desc = 'Document symbols' })
vim.keymap.set('n', '<leader>fa', require('telescope.builtin').lsp_workspace_symbols, { desc = 'Workspace symbols' })

-- LazyGit keymap
vim.keymap.set("n", "<leader>gg", ":LazyGit<CR>", { desc = "Open LazyGit" })

-- LSP keymaps
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename variable" })
vim.keymap.set("n", "<leader>gh", vim.lsp.buf.hover, { desc = "LSP Hover Info" })



-- Window/split management
vim.keymap.set('n', '<leader>sv', ':vsplit<CR>', { desc = "Split vertically" })
vim.keymap.set('n', '<leader>sh', ':split<CR>', { desc = "Split horizontally" })
vim.keymap.set('n', '<leader>se', '<C-w>=', { desc = "Make splits equal size" })
vim.keymap.set('n', '<leader>sx', ':close<CR>', { desc = "Close current split" })


-- This was made redundent by mini.default
-- -- Window navigation
-- vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = "Move to left window" })
-- vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = "Move to below window" })
-- vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = "Move to above window" })
-- vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = "Move to right window" })


-- Buffer management
vim.keymap.set('n', '<leader>bn', ':bnext<CR>', { desc = "Next buffer" })
vim.keymap.set('n', '<leader>bp', ':bprevious<CR>', { desc = "Previous buffer" })
vim.keymap.set('n', '<leader>bd', ':bdelete<CR>', { desc = "Delete buffer" })


-----------------------
-- === 5. AUTOCOMMANDS
-----------------------
-- Format on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})
