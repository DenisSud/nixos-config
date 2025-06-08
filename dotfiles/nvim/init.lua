-- ~/.config/nvim/init.lua

-- Set leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Basic settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.wrap = false
vim.opt.breakindent = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.termguicolors = true

-- Initialize mini.deps
local path_package = vim.fn.stdpath('data') .. '/site/'
local mini_path = path_package .. 'pack/deps/start/mini.nvim'
if not vim.loop.fs_stat(mini_path) then
    vim.cmd('echo "Installing `mini.nvim`" | redraw')
    local clone_cmd = {
        'git', 'clone', '--filter=blob:none',
        'https://github.com/echasnovski/mini.nvim', mini_path
    }
    vim.fn.system(clone_cmd)
    vim.cmd('packadd mini.nvim | helptags ALL')
    vim.cmd('echo "Installed `mini.nvim`" | redraw')
end

require('mini.deps').setup({ path = { package = path_package } })

local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

-- Install plugins
now(function()
    -- Telescope for fuzzy finding
    add('nvim-telescope/telescope.nvim')
    add('nvim-lua/plenary.nvim')
    add('nvim-telescope/telescope-fzf-native.nvim')

    -- LazyGit
    add('kdheepak/lazygit.nvim')

    -- File tree
    add('nvim-tree/nvim-tree.lua')
    add('nvim-tree/nvim-web-devicons')

    -- Theming
    add('RRethy/base16-nvim')

    -- LLM inline suggestions
    add("supermaven-inc/supermaven-nvim")
end)

-- Configure mini.nvim modules
now(function()
    -- mini.basics - Better default settings
    require('mini.basics').setup({
        options = {
            basic = true,
            extra_ui = true,
            win_borders = 'default',
        },
        mappings = {
            basic = true,
            option_toggle_prefix = [[\]],
            windows = true,
            move_with_alt = true,
        },
        autocommands = {
            basic = true,
        },
    })

    -- mini.starter - Start screen
    require('mini.starter').setup()

    -- mini.statusline - Status line
    require('mini.statusline').setup()

    -- mini.tabline - Tab line
    require('mini.tabline').setup()

    -- mini.clue - Show key binding hints
    require('mini.clue').setup({
        triggers = {
            { mode = 'n', keys = '<Leader>' },
            { mode = 'x', keys = '<Leader>' },
            { mode = 'n', keys = 'g' },
            { mode = 'x', keys = 'g' },
            { mode = 'n', keys = "'" },
            { mode = 'n', keys = '`' },
            { mode = 'x', keys = "'" },
            { mode = 'x', keys = '`' },
            { mode = 'n', keys = '"' },
            { mode = 'x', keys = '"' },
            { mode = 'n', keys = '<C-r>' },
            { mode = 'i', keys = '<C-r>' },
            { mode = 'c', keys = '<C-r>' },
            { mode = 'n', keys = '<C-w>' },
            { mode = 'n', keys = 'z' },
            { mode = 'x', keys = 'z' },
        },
    })
end)

later(function()
    -- mini.ai - Better text objects
    require('mini.ai').setup()

    -- mini.align - Align text
    require('mini.align').setup()

    -- mini.comment - Commenting
    require('mini.comment').setup()

    -- mini.completion - Auto completion
    require('mini.completion').setup()

    -- mini.move - Move lines/selections
    require('mini.move').setup()

    -- mini.splitjoin - Split/join arguments
    require('mini.splitjoin').setup()

    -- mini.pairs - Auto pairs
    require('mini.pairs').setup()

    -- mini.surround - Surround operations
    require('mini.surround').setup()

    -- mini.jump2d - Jump to any position
    require('mini.jump2d').setup()

    -- mini.cursorword - Highlight word under cursor
    require('mini.cursorword').setup()

    -- mini.indentscope - Indent scope visualization
    require('mini.indentscope').setup()
end)

-- Configure Telescope
later(function()
    require('telescope').setup({
        defaults = {
            mappings = {
                i = {
                    ['<C-u>'] = false,
                    ['<C-d>'] = false,
                },
            },
        },
        extensions = {
            fzf = {
                fuzzy = true,
                override_generic_sorter = true,
                override_file_sorter = true,
                case_mode = "smart_case",
            }
        }
    })

    -- Load fzf extension
    pcall(require('telescope').load_extension, 'fzf')
end)

-- Configure nvim-tree
later(function()
    require('nvim-tree').setup({
        sort_by = "case_sensitive",
        view = {
            width = 30,
        },
        renderer = {
            group_empty = true,
        },
        filters = {
            dotfiles = false,
        },
        git = {
            enable = true,
            ignore = false,
        }
    })
end)

-- Key mappings
local function map(mode, lhs, rhs, opts)
    local options = { noremap = true, silent = true }
    if opts then
        options = vim.tbl_extend('force', options, opts)
    end
    vim.keymap.set(mode, lhs, rhs, options)
end

-- Fuzzy finder mappings
map('n', '<leader>ff', '<cmd>Telescope find_files<cr>', { desc = 'Find files' })
map('n', '<leader>fw', '<cmd>Telescope live_grep<cr>', { desc = 'Find word (grep)' })
map('n', '<leader>fg', '<cmd>Telescope git_files<cr>', { desc = 'Find git files' })
map('n', '<leader>fh', '<cmd>Telescope help_tags<cr>', { desc = 'Find help' })

-- LazyGit mapping
map('n', '<leader>lg', '<cmd>LazyGit<cr>', { desc = 'LazyGit' })

-- File tree mapping
map('n', '<leader>e', '<cmd>NvimTreeToggle<cr>', { desc = 'Toggle file explorer' })

-- Additional useful mappings
map('n', '<leader>fb', '<cmd>Telescope buffers<cr>', { desc = 'Find buffers' })
map('n', '<leader>fr', '<cmd>Telescope oldfiles<cr>', { desc = 'Find recent files' })
map('n', '<leader>fc', '<cmd>Telescope commands<cr>', { desc = 'Find commands' })
map('n', '<leader>fk', '<cmd>Telescope keymaps<cr>', { desc = 'Find keymaps' })

-- Clear search highlighting
map('n', '<Esc>', '<cmd>nohlsearch<cr>')

-- Better window navigation
map('n', '<C-h>', '<C-w>h')
map('n', '<C-j>', '<C-w>j')
map('n', '<C-k>', '<C-w>k')
map('n', '<C-l>', '<C-w>l')

-- Buffer navigation
map('n', '<S-h>', '<cmd>bprevious<cr>')
map('n', '<S-l>', '<cmd>bnext<cr>')

-- Stay in indent mode
map('v', '<', '<gv')
map('v', '>', '>gv')

-- Move text up and down (handled by mini.move as well)
map('v', 'J', ":m '>+1<CR>gv=gv")
map('v', 'K', ":m '<-2<CR>gv=gv")

-- Diagnostic keymaps
map('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
map('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
map('n', '<leader>d', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
map('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- Auto commands
vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking text',
    group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})

-- LSP configuration (basic setup for PyTorch development)
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
    callback = function(event)
        local map_lsp = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        map_lsp('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
        map_lsp('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
        map_lsp('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
        map_lsp('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
        map_lsp('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
        map_lsp('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
        map_lsp('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
        map_lsp('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
        map_lsp('K', vim.lsp.buf.hover, 'Hover Documentation')
        map_lsp('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
    end,
})

vim.o.clipboard = "unnamedplus"
vim.g.base16_colorscheme = 'black-metal-gorgoroth'
vim.cmd('colorscheme base16-' .. vim.g.base16_colorscheme)
vim.opt.background = 'dark' -- Required for base16 themes
