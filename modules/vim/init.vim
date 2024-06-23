" General settings
set number
set relativenumber
set hidden
set nowrap
set tabstop=2
set shiftwidth=2
set expandtab
let mapleader = " "

" Keybindings
nnoremap <silent> <leader>pv :NvimTreeToggle<CR>
nnoremap <silent> <leader>u :UndotreeToggle<CR>
nnoremap <silent> <leader>gs :Neogit<CR>
nnoremap <silent> <C-f> <C-Right>
nnoremap <silent> <C-b> <C-Left>
vnoremap <silent> J :m '>+1<CR>gv=gv
vnoremap <silent> K :m '<-2<CR>gv=gv
nnoremap <silent> <leader>y "+y
nnoremap <silent> <leader>Y "+Y
nnoremap <silent> <leader>d "_d
nnoremap <silent> Q <nop>
nnoremap <silent> <C-c> :bd<CR>
nnoremap <silent> <leader>f :lua vim.lsp.buf.formatting()<CR>

inoremap <C-k> <Plug>luasnip-next-choice
inoremap <C-j> <Plug>luasnip-prev-choice

" Telescope keybindings
nnoremap <silent> <leader>ff :Telescope find_files<CR>
nnoremap <silent> <C-p> :Telescope git_files<CR>
nnoremap <silent> <leader>fg :Telescope live_grep<CR>
nnoremap <silent> <leader>vh :Telescope help_tags<CR>

" Harpoon keybindings
nnoremap <silent> <leader>a :lua require("harpoon.mark").add_file()<CR>
nnoremap <silent> <C-e> :lua require("harpoon.ui").toggle_quick_menu()<CR>
nnoremap <silent> <C-h> :lua require("harpoon.ui").nav_file(1)<CR>
nnoremap <silent> <C-t> :lua require("harpoon.ui").nav_file(2)<CR>
nnoremap <silent> <C-n> :lua require("harpoon.ui").nav_file(3)<CR>
nnoremap <silent> <C-s> :lua require("harpoon.ui").nav_file(4)<CR>

" LSP keybindings
nnoremap <silent> gd :lua vim.lsp.buf.definition()<CR>
nnoremap <silent> K :lua vim.lsp.buf.hover()<CR>
nnoremap <silent> <leader>vws :lua vim.lsp.buf.workspace_symbol()<CR>

