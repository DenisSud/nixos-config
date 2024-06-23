" General settings
set number
set relativenumber
set hidden
set nowrap
set tabstop=4
set shiftwidth=4
set expandtab

" Plugin configurations
call plug#begin('~/.local/share/nvim/plugged')

" LSP settings
lua << EOF
local nvim_lsp = require('lspconfig')
local cmp = require'cmp'

local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

nvim_lsp.pyright.setup {
  capabilities = capabilities,
}
nvim_lsp.rust_analyzer.setup {
  capabilities = capabilities,
}
nvim_lsp.gopls.setup {
  capabilities = capabilities,
}

cmp.setup {
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = {
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        require('luasnip').expand_or_jump()
      else
        fallback()
      end
    end,
    ['<S-Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif require('luasnip').jumpable(-1) then
        require('luasnip').jump(-1)
      else
        fallback()
      end
    end,
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'buffer' },
    { name = 'path' },
    { name = 'cmdline' },
    { name = 'luasnip' },
  },
}
EOF

" Treesitter settings
lua << EOF
require'nvim-treesitter.configs'.setup {
  ensure_installed = { "python", "rust", "go", "markdown" },
  highlight = {
    enable = true,
  },
}
EOF

" Telescope settings
lua << EOF
require('telescope').setup {
  defaults = {
    file_ignore_patterns = { "node_modules" },
  },
}
require('telescope').load_extension('fzf')
EOF

" Neogit settings
lua << EOF
require('neogit').setup {}
EOF

" nvim-tree settings
lua << EOF
require('nvim-tree').setup {}
EOF

" lualine settings
lua << EOF
require('lualine').setup {
  options = {
    theme = 'auto',
    section_separators = '',
    component_separators = ''
  }
}
EOF

" Additional plugins settings
lua << EOF
require("indent_blankline").setup {
  show_end_of_line = true,
}
require('nvim-autopairs').setup {}
require('Comment').setup {}
EOF

" Keybindings
nnoremap <leader>pv :NvimTreeToggle<CR>
nnoremap <leader>u :UndotreeToggle<CR>
nnoremap <leader>gs :Neogit<CR>
nnoremap <C-f> <C-Right>
nnoremap <C-b> <C-Left>
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv
nnoremap <leader>y "+y
nnoremap <leader>Y "+Y
nnoremap <leader>d "_d
nnoremap Q <nop>
nnoremap <C-c> :bd<CR>
nnoremap <leader>f :lua vim.lsp.buf.formatting()<CR>
imap <C-k> <Plug>luasnip-next-choice
imap <C-j> <Plug>luasnip-prev-choice

" Telescope keybindings
nnoremap <leader>pf :Telescope find_files<CR>
nnoremap <C-p> :Telescope git_files<CR>
nnoremap <leader>ps :Telescope live_grep<CR>
nnoremap <leader>vh :Telescope help_tags<CR>

" Harpoon keybindings
nnoremap <leader>a :lua require("harpoon.mark").add_file()<CR>
nnoremap <C-e> :lua require("harpoon.ui").toggle_quick_menu()<CR>
nnoremap <C-h> :lua require("harpoon.ui").nav_file(1)<CR>
nnoremap <C-t> :lua require("harpoon.ui").nav_file(2)<CR>
nnoremap <C-n> :lua require("harpoon.ui").nav_file(3)<CR>
nnoremap <C-s> :lua require("harpoon.ui").nav_file(4)<CR>

" LSP keybindings
nnoremap gd :lua vim.lsp.buf.definition()<CR>
nnoremap K :lua vim.lsp.buf.hover()<CR>
nnoremap <leader>vws :lua vim.lsp.buf.workspace_symbol()<CR>
nnoremap <leader>vd :lua vim.diagnostic.open_float()<CR>
nnoremap [d :lua vim.diagnostic.goto_prev()<CR>
nnoremap ]d :lua vim.diagnostic.goto_next()<CR>
nnoremap <leader>vca :lua vim.lsp.buf.code_action()<CR>
nnoremap <leader>vrr :lua vim.lsp.buf.references()<CR>
nnoremap <leader>vrn :lua vim.lsp.buf.rename()<CR>
nnoremap <C-h> :lua vim.lsp.buf.signature_help()<CR>
nnoremap <leader>f :lua vim.lsp.buf.formatting()<CR>
