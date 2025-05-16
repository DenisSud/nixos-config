-- Create a new file at: ~/.config/nvim/lua/plugins/lsp.lua
return {
    {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v3.x',
        dependencies = {
            -- LSP Support
            { 'neovim/nvim-lspconfig' },
            { 'hrsh7th/cmp-nvim-lsp' },
            -- Autocompletion
            { 'hrsh7th/nvim-cmp' },
            { 'hrsh7th/cmp-buffer' },
            { 'hrsh7th/cmp-path' },
            { 'saadparwaiz1/cmp_luasnip' },
            { 'hrsh7th/cmp-nvim-lua' },
            -- Snippets
            { 'L3MON4D3/LuaSnip' },
            { 'rafamadriz/friendly-snippets' },
            -- Lazy-LSP for Nix integration
            { 'dundalek/lazy-lsp.nvim' }
        },
        config = function()
            local lsp_zero = require('lsp-zero')
            lsp_zero.on_attach(function(client, bufnr)
                -- See :help lsp-zero-keybindings
                lsp_zero.default_keymaps({
                    buffer = bufnr,
                    preserve_mappings = false
                })
                -- Add any custom keymaps here
                vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { buffer = bufnr, desc = "Code actions" })
                vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { buffer = bufnr, desc = "Rename symbol" })
                vim.keymap.set('n', '<leader>lh', vim.lsp.buf.hover, { desc = 'LSP hover' })
            end)
            -- Configure completion
            local cmp = require('cmp')
            local cmp_select = { behavior = cmp.SelectBehavior.Select }
            cmp.setup({
                sources = {
                    { name = 'nvim_lsp' },
                    { name = 'luasnip' },
                    { name = 'buffer' },
                    { name = 'path' }
                },
                mapping = cmp.mapping.preset.insert({
                    ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
                    ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
                    ['<C-y>'] = cmp.mapping.confirm({ select = true }),
                    ['<C-Space>'] = cmp.mapping.complete(),
                })
            })
            -- Setup lazy-lsp
            require('lazy-lsp').setup({
                excluded_servers = {
                    "tabby_ml",
                    "markdown_oxide",
                    "pico8_ls",
                    "css_variables",
                    "delphi_ls",
                    "cue",     -- Add this line
                    "oxlint",  -- Add this line
                },
                prefer_local = false, -- Set to true if you want to prefer locally installed LSP servers
                configs = {
                    -- Add custom LSP configurations here
                    rust_analyzer = {
                        settings = {
                            ['rust-analyzer'] = {
                                checkOnSave = {
                                    command = "clippy"
                                },
                                -- Add any other rust-analyzer specific settings
                            }
                        }
                    }
                }
            })
        end
    }
}
