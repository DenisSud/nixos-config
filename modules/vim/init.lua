-- General settings
vim.o.number = true
vim.o.relativenumber = true
vim.o.hidden = true
vim.o.wrap = false
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true

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
