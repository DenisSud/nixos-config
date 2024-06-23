-- General settings
vim.o.number = true
vim.o.relativenumber = true
vim.o.hidden = true
vim.o.wrap = false
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true

-- LSP settings
-- local nvim_lsp = require('lspconfig')
-- local cmp = require('cmp')

local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

nvim_lsp.pyright.setup {
    capabilities = capabilities,
}
nvim_lsp.rust_analyzer.setup {
    capabilities = capabilities,
}
nvim_lsp.gopls.setup {
    capabilities = capabilities,
}

-- cmp.setup {
--     mapping = {
--         ['<C-d>'] = cmp.mapping.scroll_docs(-4),
--         ['<C-f>'] = cmp.mapping.scroll_docs(4),
--         ['<C-Space>'] = cmp.mapping.complete(),
--         ['<C-e>'] = cmp.mapping.close(),
--         ['<CR>'] = cmp.mapping.confirm {
--             behavior = cmp.ConfirmBehavior.Replace,
--             select = true,
--         },
--         ['<Tab>'] = function(fallback)
--             if cmp.visible() then
--                 cmp.select_next_item()
--             elseif require('luasnip').expand_or_jumpable() then
--                 require('luasnip').expand_or_jump()
--             else
--                 fallback()
--             end
--         end,
--         ['<S-Tab>'] = function(fallback)
--             if cmp.visible() then
--                 cmp.select_prev_item()
--             elseif require('luasnip').jumpable(-1) then
--                 require('luasnip').jump(-1)
--             else
--                 fallback()
--             end
--         end,
--     },
--     sources = {
--         { name = 'nvim_lsp' },
--         { name = 'buffer' },
--         { name = 'path' },
--         { name = 'cmdline' },
--         { name = 'luasnip' },
--     },
-- }

-- Treesitter settings
-- require'nvim-treesitter.configs'.setup {
--     ensure_installed = { "python", "rust", "go", "markdown" },
--     highlight = {
--         enable = true,
--     },
-- }

-- Telescope settings
-- require('telescope').setup {
--     defaults = {
--         file_ignore_patterns = { "node_modules" },
--     },
-- }
-- require('telescope').load_extension('fzf')

-- Neogit settings
require('neogit').setup {}

-- nvim-tree settings
require('nvim-tree').setup {}

-- lualine settings
require('lualine').setup {
    options = {
        theme = 'auto',
        section_separators = '',
        component_separators = ''
    }
}

-- Keybindings
vim.api.nvim_set_keymap('n', '<leader>pv', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>u', ':UndotreeToggle<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>gs', ':Neogit<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-f>', '<C-Right>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-b>', '<C-Left>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', 'J', ':m \'>+1<CR>gv=gv', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', 'K', ':m \'<-2<CR>gv=gv', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>y', '"+y', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>Y', '"+Y', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>d', '"_d', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'Q', '<nop>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-c>', ':bd<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>f', ':lua vim.lsp.buf.formatting()<CR>', { noremap = true, silent = true })

vim.api.nvim_set_keymap('i', '<C-k>', '<Plug>luasnip-next-choice', {})
vim.api.nvim_set_keymap('i', '<C-j>', '<Plug>luasnip-prev-choice', {})

-- Telescope keybindings
vim.api.nvim_set_keymap('n', '<leader>pf', ':Telescope find_files<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-p>', ':Telescope git_files<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>ps', ':Telescope live_grep<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>vh', ':Telescope help_tags<CR>', { noremap = true, silent = true })

-- Harpoon keybindings
vim.api.nvim_set_keymap('n', '<leader>a', ':lua require("harpoon.mark").add_file()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-e>', ':lua require("harpoon.ui").toggle_quick_menu()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-h>', ':lua require("harpoon.ui").nav_file(1)<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-t>', ':lua require("harpoon.ui").nav_file(2)<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-n>', ':lua require("harpoon.ui").nav_file(3)<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-s>', ':lua require("harpoon.ui").nav_file(4)<CR>', { noremap = true, silent = true })

-- LSP keybindings
vim.api.nvim_set_keymap('n', 'gd', ':lua vim.lsp.buf.definition()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'K', ':lua vim.lsp.buf.hover()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>vws', ':lua vim.lsp.buf.workspace_symbol()<CR>', { noremap = true, silent = true })
