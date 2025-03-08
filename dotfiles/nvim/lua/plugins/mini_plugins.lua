return {
    'echasnovski/mini.nvim',
    config = function()
        -- mini.ai: Improves text object selections.
        require('mini.ai').setup({
            custom_textobjects = {
                [';'] = require('mini.ai').gen_spec.treesitter({
                    a = '@call.outer',
                    i = '@call.inner',
                }),
            },
        })
        -- (No additional keymaps needed; mini.ai integrates with Vim’s native text object commands.)

        -- mini.comment: Toggle comments.
        require('mini.comment').setup()
        vim.keymap.set("n", "gcc", require("mini.comment").toggle, { desc = "Toggle comment" })
        vim.keymap.set("x", "gc", require("mini.comment").toggle, { desc = "Toggle comment" })

        -- mini.pairs: Automatic pairing (no mapping needed).
        require('mini.pairs').setup()

        -- mini.splitjoin: Toggle between single-line and multi-line forms.
        require('mini.splitjoin').setup()
        vim.keymap.set("n", "gs", require("mini.splitjoin").toggle, { desc = "Toggle split/join" })
        vim.keymap.set("x", "gs", require("mini.splitjoin").toggle, { desc = "Toggle split/join" })

        -- mini.surround: Add, delete, or replace surroundings.
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
        vim.keymap.set("n", "ys", require("mini.surround").add, { desc = "Add surrounding" })
        vim.keymap.set("n", "ds", require("mini.surround").delete, { desc = "Delete surrounding" })
        vim.keymap.set("n", "cs", require("mini.surround").replace, { desc = "Replace surrounding" })

        -- mini.completion: Completion mappings are set during setup.
        require('mini.completion').setup({
            delay = { completion = 150, info = 1000 },
            mappings = {
                force_twoway_next = '<C-n>',
                force_twoway_prev = '<C-p>',
                force_fallback = '<C-Space>',
            },
        })

        -- mini.statusline: Statusline setup (no mapping required).
        require('mini.statusline').setup()

        -- mini.tabline: Tabline setup (no mapping required).
        require('mini.tabline').setup()

        -- mini.files: File explorer.
        require('mini.files').setup()
        vim.keymap.set("n", "<leader>m", require("mini.files").open, { desc = "Open MiniFiles" })

        -- mini.git: Git integration.
        require('mini.git').setup()
        -- If available, set keymaps for hunk navigation.
        if require("mini.git").hunk_next then
            vim.keymap.set("n", "<leader>gj", require("mini.git").hunk_next, { desc = "Next git hunk" })
            vim.keymap.set("n", "<leader>gk", require("mini.git").hunk_prev, { desc = "Previous git hunk" })
        end

        -- mini.starter: Startup screen.
        require('mini.starter').setup()
        if require("mini.starter").open then
            vim.keymap.set("n", "<leader>ss", require("mini.starter").open, { desc = "Open Starter" })
        end

        -- mini.doc: Documentation browsing.
        require('mini.doc').setup()
        if require("mini.doc").open then
            vim.keymap.set("n", "<leader>md", require("mini.doc").open, { desc = "Open MiniDoc" })
        end
    end,
}
