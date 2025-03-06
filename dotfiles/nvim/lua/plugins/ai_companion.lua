return {
    'olimorris/codecompanion.nvim',
    config = function()
        require("codecompanion").setup({
            -- Configuration options
            -- Default values shown

            -- Provider settings (one or more required)
            -- You can use multiple providers at the same time.
            providers = {
                openai = {
                    api_key = os.getenv("OPENAI_API_KEY"), -- Required
                    model = "gpt-3.5-turbo",              -- Optional (Defaults to gpt-3.5-turbo)
                    max_tokens = 150,                    -- Optional (Defaults to 150)
                    temperature = 0.2,                   -- Optional (Defaults to 0.2)
                },
            },

            -- Keymaps
            keymaps = {
                ask = "<leader>ca",          -- Ask a question about the current code
                explain = "<leader>ce",      -- Explain the current code
                generate_tests = "<leader>ct", -- Generate tests for the current code
                document = "<leader>cd",       -- Generate documentation for the current code
            },

            -- UI settings
            ui = {
                -- Float window settings
                float = {
                    border = "rounded",      -- Border style. (see `:h nvim_open_win`)
                    winblend = 30,           -- Window blend. (see `:h winblend`)
                    title_pos = "center",      -- Title position. "left", "center", or "right"
                },

                -- Markdown preview settings
                markdown = {
                    width = 80,              -- Width of the preview window
                    highlights = {            -- Table of highlight groups
                        ["mkdTableDelim"] = "String",
                        ["mkdTable"] = "Comment",
                    },
                },
            },

            -- Experimental features
            experimental = {
                edit = {
                    enabled = false,         -- Enable edit mode
                    keymap = "<leader>ee",   -- Keymap to toggle edit mode
                },
            },
        })
    end,
}