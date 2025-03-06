return {
    "simrat39/symbols-outline.nvim",
    config = function()
        require("symbols-outline").setup({
            auto_close = true,
        })
        vim.keymap.set("n", "<leader>so", ":SymbolsOutline<CR>", { desc = "Toggle Symbols Outline" })
    end,
}