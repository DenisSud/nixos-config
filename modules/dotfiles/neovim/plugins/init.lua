-- Telescope setup
require("telescope").setup{
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
lspconfig.pyright.setup({
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "off",
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
      }
    }
  },
  filetypes = { "python" },
})

-- Jupytext setup
require('jupytext').setup({
  style = "markdown",
  autosync = true,
  sync_patterns = { '*.md', '*.py', '*.ipynb' },
})

-- Gitsigns setup
require("gitsigns").setup{
  on_attach = function(bufnr)
    if vim.api.nvim_buf_get_name(bufnr):match('%.ipynb$') then
      return false
    end
    -- Default gitsigns setup
    local gs = package.loaded.gitsigns
    vim.keymap.set('n', '<leader>hp', gs.preview_hunk, { buffer = bufnr, desc = "Preview git hunk" })
    vim.keymap.set('n', '<leader>hb', gs.blame_line, { buffer = bufnr, desc = "Blame line" })
  end,
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

-- Lualine setup
require("lualine").setup{
  options = {
    theme = "auto",
    component_separators = "|",
    section_separators = "",
  },
}

-- DAP setup
local dap = require('dap')
local dapui = require('dapui')

dapui.setup()
require('dap-python').setup('python')

-- Conform setup
require("conform").setup({
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
