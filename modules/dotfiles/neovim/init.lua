-- General Settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.smartindent = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.updatetime = 50
vim.opt.laststatus = 3  -- recommended setting for avante
vim.opt.clipboard = "unnamedplus"

-- Improve default formatting and indentation
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.cindent = true

-- Fine-tune indentation for specific filetypes
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"python", "lua", "nix", "rust", "typescript", "javascript"},
  callback = function()
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
    vim.opt_local.expandtab = true
  end
})

-- Leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Dynamically set Base16 theme
-- local base16_scheme = os.getenv("BASE16_THEME") or "default-dark"
-- vim.cmd("colorscheme base16-" .. base16_scheme)

-- Telescope setup and keybindings
local telescope = require("telescope")
telescope.setup{
  defaults = {
    file_ignore_patterns = { "node_modules", ".git" },
    mappings = {
      i = {
        ["<C-j>"] = "move_selection_next",
        ["<C-k>"] = "move_selection_previous",
      }
    }
  }
}

-- Telescope keymaps
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
vim.keymap.set("n", "<leader>fs", builtin.git_status, { desc = "Git status" })

-- nvim-cmp setup
local cmp = require("cmp")
local luasnip = require("luasnip")

require("luasnip.loaders.from_vscode").lazy_load()

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "luasnip" },
    { name = "buffer" },
    { name = "path" },
  }),
})

-- LSP setup
local lspconfig = require("lspconfig")

-- Basic LSP keybindings
vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover documentation" })
vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename" })
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })

-- Gitsigns setup
require("gitsigns").setup{
  signs = {
    add = { text = "+" },
    change = { text = "~" },
    delete = { text = "_" },
    topdelete = { text = "‾" },
    changedelete = { text = "~" },
  },
}

-- nvim-tree setup
require("nvim-tree").setup{
  sort_by = "case_sensitive",
  view = {
    width = 30,
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = true,
  },
}

-- File explorer keybinding
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle file explorer" })

-- Lualine setup
require("lualine").setup{
  options = {
    theme = "auto",
    component_separators = "|",
    section_separators = "",
  },
}

-- Optional: Conform.nvim for formatting
local conform = require("conform")
conform.setup({
  formatters_by_ft = {
    lua = { "stylua" },
    python = { "black" },
    nix = { "nixpkgs-fmt" },
    rust = { "rustfmt" },
    javascript = { "prettier" },
    typescript = { "prettier" },
  },
  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },
})

-- Manual formatting keybinding
vim.keymap.set("n", "<leader>f", function()
  conform.format({ async = true, lsp_fallback = true })
end, { desc = "Format buffer" })

-- Jupytext configuration
require('jupytext').setup({
  style = "markdown",
  autosync = true,
  sync_patterns = { '*.md', '*.py', '*.ipynb' },
})

-- Disable gitsigns for ipynb files as recommended in jupytext docs
require('gitsigns').setup{
  on_attach = function(bufnr)
    if vim.api.nvim_buf_get_name(bufnr):match('%.ipynb$') then
      return false
    end
    -- Your existing gitsigns config here
  end,
}

-- DAP configuration for Python debugging
local dap = require('dap')
local dapui = require('dapui')

-- Initialize DAP UI
dapui.setup()

-- Python adapter setup
require('dap-python').setup('python')

-- Debugging keymaps
vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
vim.keymap.set('n', '<leader>dc', dap.continue, { desc = "Continue" })
vim.keymap.set('n', '<leader>dj', dap.step_over, { desc = "Step over" })
vim.keymap.set('n', '<leader>dl', dap.step_into, { desc = "Step into" })
vim.keymap.set('n', '<leader>dh', dap.step_out, { desc = "Step out" })
vim.keymap.set('n', '<leader>dt', dapui.toggle, { desc = "Toggle DAP UI" })

-- Python-specific settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"python", "ipynb"},
  callback = function()
    -- Use black line length of 88
    vim.opt_local.textwidth = 88
    -- Configure conform.nvim for Python files
    require("conform").setup({
      formatters_by_ft = {
        python = { "black" },
      },
    })
  end
})

-- Make LSP work better with Jupyter notebooks
local lspconfig = require('lspconfig')
lspconfig.pyright.setup({
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "off",  -- Less strict for notebook-style development
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
      }
    }
  },
  -- Don't run LSP in ipynb files as it can be noisy
  filetypes = { "python" },
})
