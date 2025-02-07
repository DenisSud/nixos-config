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

-- Basic vim settings
vim.o.clipboard = "unnamedplus"
vim.wo.number = true
vim.wo.relativenumber = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.smartindent = true
vim.o.laststatus = 3
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.splitbelow = true
vim.o.splitright = true
vim.g.mapleader = " "

-- Plugin specifications
require("lazy").setup({
    -- Core plugins
    {
        'nvim-lua/plenary.nvim',
        lazy = false,
    },
    {
        'nvim-telescope/telescope.nvim',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = function()
        require('telescope').setup{
            defaults = {
                file_ignore_patterns = {"node_modules", ".git"},
            }
        }
        -- Telescope keymaps
        vim.keymap.set('n', '<Leader>ff', ':Telescope find_files<CR>', { noremap = true, silent = true })
        vim.keymap.set('n', '<Leader>fg', ':Telescope live_grep<CR>', { noremap = true, silent = true })
        vim.keymap.set('n', '<Leader>fb', ':Telescope buffers<CR>', { noremap = true, silent = true })
        vim.keymap.set('n', '<Leader>fh', ':Telescope help_tags<CR>', { noremap = true, silent = true })
        end,
    },

    -- LSP plugins
    {
        "williamboman/mason.nvim",
        config = function()
        require("mason").setup()
        end,
    },
    {
        "williamboman/mason-lspconfig.nvim",
        config = function()
        require("mason-lspconfig").setup({
            ensure_installed = { "lua_ls", "pyright" },
            automatic_installation = true
        })
        end,
    },
    {
        "neovim/nvim-lspconfig",
        config = function()
        local lspconfig = require('lspconfig')

        -- Basic LSP setup
        local on_attach = function(client, bufnr)
        -- LSP keybindings
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = bufnr })
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = bufnr })
        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { buffer = bufnr })
        vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { buffer = bufnr })
        end

        -- Configure language servers
        lspconfig.lua_ls.setup({ on_attach = on_attach })
        lspconfig.pyright.setup({ on_attach = on_attach })
        lspconfig.clangd.setup({ on_attach = on_attach })

        -- Enable diagnostics
        vim.diagnostic.config({
            virtual_text = true,
            signs = true,
            update_in_insert = false
        })
        end,
    },

    -- Mini plugins
    {
        'echasnovski/mini.nvim',
        config = function()
            -- Text Editing: Modules that directly modify or enhance your text-manipulation abilities.
            require('mini.ai').setup()
            require('mini.align').setup()
            require('mini.comment').setup()
            require('mini.pairs').setup()
            require('mini.surround').setup()
            require('mini.completion').setup({
                lsp_completion = { source = 'lsp' },
                mappings = {
                    force_twoway_next = '<C-n>',
                    force_twoway_prev = '<C-p>'
                }
            })

            -- Workflow: Modules that improve your overall editing flow and navigation.
            require('mini.basics').setup()
            require('mini.bracketed').setup()
            require('mini.doc').setup()
            require('mini.git').setup()
            require('mini.clue').setup()
            require('mini.pick').setup()
            require('mini.jump').setup()
            require('mini.notify').setup()
            require('mini.starter').setup()

            -- Visual: Modules that affect the look and feel of your Neovim interface.
            require('mini.statusline').setup()
            require('mini.tabline').setup()
            require('mini.icons').setup()
            require('mini.cursorword').setup()
            require('mini.hipatterns').setup()
            require('mini.indentscope').setup()
            require('mini.trailspace').setup()

            -- Miscellaneous: Modules that don’t clearly fall into the above categories.
            require('mini.deps').setup()
        end,
    },

    -- AI assistance plugins
    {
        'supermaven-inc/supermaven-nvim',
        config = function()
        require("supermaven-nvim").setup({
            keymaps = {
                accept_suggestion = "<Tab>",
                clear_suggestion = "<C-]>",
                accept_word = "<C-j>",
            },
            ignore_filetypes = { cpp = true },
            color = {
                suggestion_color = "#ffffff",
                cterm = 244,
            },
            log_level = "off",
            disable_inline_completion = false,
            disable_keymaps = false,
            condition = function()
            return false
            end
        })
        end,
    },
})

-- Basic keymaps
vim.keymap.set('n', '<C-s>', ':w<CR>', { noremap = true, silent = true })
vim.keymap.set('n', 'j', 'gj', { noremap = true })
vim.keymap.set('n', 'k', 'gk', { noremap = true })

-- Autocommands
vim.api.nvim_create_autocmd("TextYankPost", {
    pattern = "*",
    callback = function()
    vim.highlight.on_yank({ timeout = 200 })
    end,
})

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
    end
})
