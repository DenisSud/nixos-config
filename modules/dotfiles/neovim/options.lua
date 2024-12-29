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
vim.opt.laststatus = 3
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

-- Python-specific settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"python", "ipynb"},
  callback = function()
    vim.opt_local.textwidth = 88
  end
})

-- Leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "
