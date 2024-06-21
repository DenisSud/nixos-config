" Set mapleader
let mapleader = " "

" Leader key to open Ex mode
nnoremap <leader>ls :Ex<CR>

" Visual mode join lines using yank and paste
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

" Normal mode join lines with yank and paste
nnoremap J mzJ`z
nnoremap n nzzzv
nnoremap N Nzzzv

" Leader key to restart LSP
nnoremap <leader>zig :LspRestart<CR>

" Leader key for vim-with-me functions (assuming plugin is installed)
nnoremap <leader>vwm <cmd>VimWithMeStart<CR>
nnoremap <leader>svwm <cmd>VimWithMeStop<CR>

" Greatest remap ever (leader + p for paste)
xnoremap <leader>p [["_dP]]

" Next greatest remap ever (leader + y/Y for yank)
nnoremap <leader>y [["+y"]]
nnoremap <leader>Y [["+Y"]]

" Leader key for yank in normal and visual mode (assuming plugin is installed)
nnoremap <leader>d [["_d"]]
vnoremap <leader>d [["_d"]]

" Remap Ctrl-C in insert mode to escape
inoremap <C-c> <Esc>

" Nop for key Q
nnoremap Q <Nop>

" Leader key to format buffer (assuming LSP is enabled)
nnoremap <leader>f :LspBufFmt<CR>

" Switch buffers with Ctrl-k/j and leader+k/j (assuming plugin is installed)
nnoremap <C-k> <cmd>cnext<CR>zz
nnoremap <C-j> <cmd>cprev<CR>zz
nnoremap <leader>k <cmd>lnext<CR>zz
nnoremap <leader>j <cmd>lprev<CR>zz

" Leader key for complex search and replace
nnoremap <leader>s [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]]

" Leader key to chmod +x current file silently
nnoremap <leader>x <cmd>!chmod +x %<CR> > /dev/null 2>&1

" Leader leader to source file (assuming plugin is installed)
nnoremap <leader><leader> :source %<CR>

" Leader key to find files with telescope (assuming plugin is installed)
nnoremap <leader>ff <cmd>Telescope find_files<CR>
