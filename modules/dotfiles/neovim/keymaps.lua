-- Telescope keymaps
local telescope = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", telescope.find_files, { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", telescope.live_grep, { desc = "Live grep" })
vim.keymap.set("n", "<leader>fb", telescope.buffers, { desc = "Find buffers" })
vim.keymap.set("n", "<leader>fh", telescope.help_tags, { desc = "Help tags" })
vim.keymap.set("n", "<leader>fs", telescope.git_status, { desc = "Git status" })

-- LSP keymaps
vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover documentation" })
vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename" })
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })

-- File explorer keybinding
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle file explorer" })

-- Formatting keybinding
vim.keymap.set("n", "<leader>f", function()
  require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "Format buffer" })

-- DAP keymaps
local dap = require('dap')
local dapui = require('dapui')
vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
vim.keymap.set('n', '<leader>dc', dap.continue, { desc = "Continue" })
vim.keymap.set('n', '<leader>dj', dap.step_over, { desc = "Step over" })
vim.keymap.set('n', '<leader>dl', dap.step_into, { desc = "Step into" })
vim.keymap.set('n', '<leader>dh', dap.step_out, { desc = "Step out" })
vim.keymap.set('n', '<leader>dt', dapui.toggle, { desc = "Toggle DAP UI" })
