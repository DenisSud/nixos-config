-- lua/plugins/mason.lua
return {
    "williamboman/mason.nvim",
    dependencies = {
        "williamboman/mason-lspconfig.nvim",
        "neovim/nvim-lspconfig",
    },
    config = function()
        require("mason").setup()
        require("mason-lspconfig").setup({
            ensure_installed = {
                "lua_ls",
                "ruff_lsp",
                "clangd",
                "texlab",
                "pyright", -- Good for ML/PyTorch code
            },
            automatic_installation = true,
        })

        -- This will be called after servers are installed
        require("mason-lspconfig").setup_handlers({
            function(server_name)
                require("lspconfig")[server_name].setup({
                    on_attach = function(_, bufnr)
                        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = bufnr })
                        vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = bufnr })
                        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { buffer = bufnr })
                        vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { buffer = bufnr })
                    end,
                    -- You can add server-specific settings here
                })
            end,

            -- Override specific server configurations if needed
            ["ruff_lsp"] = function()
                require("lspconfig").ruff_lsp.setup({
                    on_attach = function(_, bufnr)
                        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = bufnr })
                        vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = bufnr })
                        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { buffer = bufnr })
                        vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { buffer = bufnr })
                        vim.keymap.set('n', '<leader>rr', function()
                            vim.cmd('LspRestart ruff_lsp')
                        end, { buffer = true, desc = "Restart Ruff LSP server" })
                    end,
                    init_options = {
                        settings = {
                            organizeImports = true,
                            fixAll = true
                        }
                    }
                })
            end,
        })
    end,
}
