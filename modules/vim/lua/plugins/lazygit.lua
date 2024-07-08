local plugins = {
  "jesseduffield/lazygit",
  cmd = "LazyGit",
  config = function()
    require("configs.lazygit-config")
  end
}

return plugins
