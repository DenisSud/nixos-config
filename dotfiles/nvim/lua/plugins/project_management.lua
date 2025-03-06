return {
    "ahmedkhalf/project.nvim",
    config = function()
        require("project_nvim").setup({
            detection_methods = { "pattern" },
            patterns = { ".git", "pyproject.toml", "setup.py", "requirements.txt" },
            show_hidden = false,
        })
    end,
}