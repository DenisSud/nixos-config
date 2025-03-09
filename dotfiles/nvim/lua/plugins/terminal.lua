return {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
        require("toggleterm").setup({
            size = 20,
            open_mapping = [[<C-\>]],
            hide_numbers = true,
            shade_terminals = true,
            shading_factor = 2,
            start_in_insert = true,
            insert_mappings = true,
            persist_size = true,
            direction = "float", -- 'vertical', 'horizontal', 'tab', 'float'
            close_on_exit = true,
            shell = vim.o.shell,
            float_opts = {
                border = "curved",
                winblend = 0,
                highlights = {
                    border = "Normal",
                    background = "Normal",
                }
            }
        })

        -- Terminal keymaps
        function _G.set_terminal_keymaps()
            local opts = { buffer = 0 }
            vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
            vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts)
            vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
            vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
            vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
            vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
        end

        -- Auto command to set terminal keymaps when terminal opens
        vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')

        -- Add leader keymaps for terminal
        vim.keymap.set('n', '<leader>tf', ':ToggleTerm direction=float<CR>', { desc = "Toggle floating terminal" })
        vim.keymap.set('n', '<leader>th', ':ToggleTerm direction=horizontal<CR>',
            { desc = "Toggle horizontal terminal" })
        vim.keymap.set('n', '<leader>tv', ':ToggleTerm direction=vertical<CR>', { desc = "Toggle vertical terminal" })
    end
}

