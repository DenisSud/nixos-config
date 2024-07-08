
local present, lazygit = pcall(require, "lazygit")

if not present then
  return
end

lazygit.setup({
  settings = {
    winHeight = 40,
    winWidth = 80,
    side = "right",
    diff_context_lines = 5,
    diff_split_hunk = false,
    diff_tab_size = 4,
    diff_style = "split",
    diff_tool = "vimdiff",
    diff_opts = {
      internal = true,
      algo = "myers",
      indent-heuristic = true,
      algorithm = "histogram",
    },
  },
})
