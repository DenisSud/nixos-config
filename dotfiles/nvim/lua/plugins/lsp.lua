return {
    "neovim/nvim-lspconfig",
    -- This is now managed by mason.lua, so we can simplify this file
    config = function()
        -- Diagnostic configuration
        vim.diagnostic.config({
            virtual_text = true,
            signs = true,
            update_in_insert = false,
        })
    end,
}
