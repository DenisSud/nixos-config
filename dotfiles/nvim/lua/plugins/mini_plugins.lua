return {
    'echasnovski/mini.nvim',
    config = function()
        -- mini.ai: Text object enhancements.
        local mini_ai = require('mini.ai')
        mini_ai.setup({
            custom_textobjects = {
                [';'] = mini_ai.gen_spec.treesitter({
                    a = '@call.outer',
                    i = '@call.inner',
                }),
            },
        })

        -- mini.fuzzy: Fuzzy finder.
        require('mini.fuzzy').setup()

        -- mini.comment: Toggle comments.
        require('mini.comment').setup()
        if require("mini.comment").toggle then
            vim.keymap.set("n", "gcc", require("mini.comment").toggle, { desc = "Toggle comment" })
            vim.keymap.set("x", "gc", require("mini.comment").toggle, { desc = "Toggle comment" })
        end

        -- mini.pairs: Automatic pairing.
        require('mini.pairs').setup()

        -- mini.splitjoin: Toggle split/join.
        require('mini.splitjoin').setup()
        if require("mini.splitjoin").toggle then
            vim.keymap.set("n", "gs", require("mini.splitjoin").toggle, { desc = "Toggle split/join" })
            vim.keymap.set("x", "gs", require("mini.splitjoin").toggle, { desc = "Toggle split/join" })
        end

        -- mini.surround: Add, delete, or replace surroundings.
        require('mini.surround').setup()

        -- mini.completion: Code completion.
        require('mini.completion').setup({
            delay = { completion = 150, info = 1000 },
            mappings = {
                force_twoway_next = '<C-n>',
                force_twoway_prev = '<C-p>',
                force_fallback = '<C-Space>',
            },
        })

        -- mini.statusline: Statusline.
        require('mini.statusline').setup()

        -- mini.tabline: Tabline.
        require('mini.tabline').setup()
        require('mini.icons').setup()

        -- mini.files: File explorer.
        local mini_files = require('mini.files')
        mini_files.setup()
        if mini_files.open then
            vim.keymap.set("n", "<leader>m", mini_files.open, { desc = "Open MiniFiles" })
        end

        -- mini.starter: Startup screen.
        local mini_starter = require('mini.starter')
        mini_starter.setup()
        if mini_starter.open then
            vim.keymap.set("n", "<leader>ss", mini_starter.open, { desc = "Open Starter" })
        end

        -- mini.doc: Documentation.
        local mini_doc = require('mini.doc')
        mini_doc.setup()
        if mini_doc.open then
            vim.keymap.set("n", "<leader>md", mini_doc.open, { desc = "Open MiniDoc" })
        end
    end,
}
