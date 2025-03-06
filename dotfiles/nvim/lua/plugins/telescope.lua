return {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
        require('telescope').setup {
            defaults = {
                file_ignore_patterns = { "node_modules", ".git" },
            },
            extensions = {
                file_browser = {
                    hijack_netrw = true,
                },
            },
        }

        -- Telescope keymaps
        vim.keymap.set('n', '<leader>ff', ':Telescope find_files<CR>', { silent = true })
        vim.keymap.set('n', '<leader>fg', ':Telescope live_grep<CR>', { silent = true })
        vim.keymap.set('n', '<leader>fb', ':Telescope buffers<CR>', { silent = true })
        vim.keymap.set('n', '<leader>fh', ':Telescope help_tags<CR>', { silent = true })
    end,
}