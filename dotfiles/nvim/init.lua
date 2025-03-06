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
    require("plugins.terminal"),           -- plugins/terminal.lua
    require("plugins.telescope"),          -- plugins/telescope.lua
    require("plugins.symbols_outline"),    -- plugins/symbols_outline.lua
    require("plugins.git"),                -- plugins/git.lua
    require("plugins.project_management"), -- plugins/project_management.lua
    require("plugins.ai_companion"),       -- plugins/ai_companion.lua
    require("plugins.lsp"),                -- plugins/lsp.lua
    require("plugins.completion"),         -- plugins/completion.lua
    require("plugins.mini_plugins"),       -- plugins/mini_plugins.lua
    require("plugins.ai_assistance"),      -- plugins/ai_assistance.lua
})

-------------------
-- === 4. KEYMAPS
-------------------
-- General keymaps
vim.keymap.set('n', '<Space>', ':w<CR>', { silent = true })
vim.keymap.set('n', 'j', 'gj', { remap = true })
vim.keymap.set('n', 'k', 'gk', { remap = true })

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
-- Highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
    pattern = "*",
    callback = function()
        vim.highlight.on_yank({ timeout = 200 })
    end,
})

-- Remove automatic comment insertion
vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*",
    callback = function()
        vim.opt.formatoptions:remove("c")
    end,
})

-- Format on save
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    callback = function()
        vim.lsp.buf.format({ async = false })
    end,
})

-- Python-specific settings
local hipatterns = require('mini.hipatterns')

vim.api.nvim_create_autocmd("FileType", {
    pattern = "python",
    callback = function()
        -- Check if enable_highlight exists in the module
        if hipatterns.enable_highlight then
            hipatterns.enable_highlight('python_docstrings', {
                pattern = [[\V"""\V.*]],
                group = 'SpecialComment',
            })
        else
            print("Warning: enable_highlight function not found in mini.hipatterns")
        end


        -- Set up the key mapping for restarting the Ruff LSP server
        vim.keymap.set('n', '<leader>rr', function()
            vim.cmd('LspRestart ruff')
        end, { buffer = true, desc = "Restart Ruff LSP server" })
    end,
})
