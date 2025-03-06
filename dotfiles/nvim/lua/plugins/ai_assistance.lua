return {
    'new_package/ai_assistance', -- Replace with the new package's name
    config = function()
        -- Add configuration options for the new package
        require("ai_assistance").setup({ -- Adjust require path if needed
            keymaps = {
                accept_suggestion = "<Tab>",
                clear_suggestion = "<C-]>",
                accept_word = "<C-j>",
            },
            log_level = "off", -- set to "off" to disable logging completely
        })
    end,
}
