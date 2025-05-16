return {
  'augmentcode/augment.vim', -- The plugin repository
  config = function()
    vim.api.nvim_set_keymap('n', '<leader>ac', ':Augment chat<CR>', { noremap = true, silent = true })
    vim.api.nvim_set_keymap('v', '<leader>ac', ':Augment chat<CR>', { noremap = true, silent = true })
    vim.api.nvim_set_keymap('n', '<leader>an', ':Augment chat-new<CR>', { noremap = true, silent = true })
  end,
}
