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
vim.o.tabstop = 4
vim.o.shiftwidth = 4
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
    require("plugins.core_utils"),         -- plugins/core_utils.lua
    require("plugins.base16_theme"),       -- plugins/base16_theme.lua
    require("plugins.telescope"),
    require("plugins.git"),
    require("plugins.mason"),
    require("plugins.mini")
})

-------------------
-- === 4. KEYMAPS
-------------------
-- General keymaps
vim.keymap.set('n', 'j', 'gj', { remap = true })
vim.keymap.set('n', 'k', 'gk', { remap = true })
vim.keymap.set('n', '<Space>', ':w<CR>') 

-- Telescope keymaps
vim.keymap.set('n', '<leader>ff', require('telescope.builtin').find_files, { desc = 'Find files' })
vim.keymap.set('n', '<leader>fg', require('telescope.builtin').live_grep, { desc = 'Live grep' })
vim.keymap.set('n', '<leader>fj', require('telescope.builtin').grep_string, { desc = 'Grep string' })
vim.keymap.set('n', '<leader>fb', require('telescope.builtin').buffers, { desc = 'Find buffers' })
vim.keymap.set('n', '<leader>fh', require('telescope.builtin').help_tags, { desc = 'Help tags' })
vim.keymap.set('n', '<leader>fs', require('telescope.builtin').lsp_document_symbols, { desc = 'Document symbols' })
vim.keymap.set('n', '<leader>fa', require('telescope.builtin').lsp_workspace_symbols, { desc = 'Workspace symbols' })

-- Files keymap
vim.keymap.set('n', '<leader>e', function() 
  MiniFiles.open(vim.api.nvim_buf_get_name(0))
end)

-- LazyGit keymap
vim.keymap.set("n", "<leader>gg", ":LazyGit<CR>", { desc = "Open LazyGit" })

-- LSP keymaps
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename variable" })


-- Window/split management
vim.keymap.set('n', '<leader>sv', ':vsplit<CR>', { desc = "Split vertically" })
vim.keymap.set('n', '<leader>sh', ':split<CR>', { desc = "Split horizontally" })
vim.keymap.set('n', '<leader>se', '<C-w>=', { desc = "Make splits equal size" })
vim.keymap.set('n', '<leader>sx', ':close<CR>', { desc = "Close current split" })


-- Window navigation
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = "Move to left window" })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = "Move to below window" })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = "Move to above window" })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = "Move to right window" })


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
