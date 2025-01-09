return {
  setup = function()
    require('jupytext').setup({
      style = "markdown",
      autosync = true,
      sync_patterns = { '*.md', '*.py', '*.ipynb' },
    })
  end
}
