return {
    "neovim/nvim-lspconfig",
    config = function()
        local lspconfig = require('lspconfig')
        -- LSP Setup
        local on_attach = function(_, bufnr) -- Renamed client to _ to avoid unused variable warning
            vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = bufnr })
            vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = bufnr })
            vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { buffer = bufnr })
            vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { buffer = bufnr })
        end

        -- Language server setups
        lspconfig.lua_ls.setup({
            cmd = { "/home/denis/.nix-profile/bin/lua-language-server" },
            on_attach = on_attach
        })

        lspconfig.ruff.setup({
            cmd = { "/home/denis/.nix-profile/bin/ruff-lsp" },
            on_attach = on_attach,
            init_options = {
                settings = {
                    interpreter = { "/home/denis/.nix-profile/bin/python" },
                    organizeImports = true,
                    fixAll = true
                }
            }
        })

        lspconfig.clangd.setup({
            cmd = { "/home/denis/.nix-profile/bin/clangd" },
            on_attach = on_attach
        })

        lspconfig.texlab.setup({
            cmd = { "/home/denis/.nix-profile/bin/texlab" },
            on_attach = on_attach,
        })

        -- Diagnostic configuration
        vim.diagnostic.config({
            virtual_text = true,
            signs = true,
            update_in_insert = false,
        })
    end,
}
