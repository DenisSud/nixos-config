return {
    'echasnovski/mini.nvim',
    config = function()
        -- Text objects and enhancements
        require('mini.ai').setup({
            custom_textobjects = {
                [';'] = require('mini.ai').gen_spec.treesitter({
                    a = '@call.outer',
                    i = '@call.inner',
                }),
            },
        })

        -- Text manipulation
        require('mini.align').setup()
        require('mini.comment').setup()
        require('mini.pairs').setup()
        require('mini.surround').setup({
            custom_surroundings = {
                ['f'] = {
                    input = { '%f[%a]()%F[%A]', '^.-%(.*%)' },
                    output = function()
                        local func = vim.fn.input('Function: ')
                        return { left = func .. '(', right = ')' }
                    end,
                },
            },
        })

        -- Completion
        require('mini.completion').setup({
            delay = { completion = 150, info = 1000 },
            mappings = {
                force_twoway_next = '<C-n>',
                force_twoway_prev = '<C-p>',
                force_fallback = '<C-Space>',
            },
        })

        -- UI elements
        require('mini.statusline').setup()
        require('mini.tabline').setup()
        require('mini.files').setup()
        require('mini.git').setup()
        require('mini.starter').setup()
    end,
}