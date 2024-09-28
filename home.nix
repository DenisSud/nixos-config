{ config, pkgs, ... }:
{

  home.username = "denis";
  home.homeDirectory = "/home/denis";

  programs = {

    neovim = {

      enable = false;       # Enable Neovim
      defaultEditor = true; # Set Neovim as the default editor
      viAlias = true;      # Create an alias for 'vi'
      vimAlias = true;     # Create an alias for 'vim'

      # Additional configuration as a string
      extraConfig = ''
      -- Packer plugin manager setup
vim.cmd [[packadd packer.nvim]]

require('packer').startup(function(use)
  -- Existing plugins
  use 'wbthomason/packer.nvim'
  use {
    'williamboman/mason.nvim',
    'neovim/nvim-lspconfig',
    'williamboman/mason-lspconfig.nvim'
  }
  use {
    'nvim-telescope/telescope.nvim',
    requires = { 'nvim-lua/plenary.nvim' }
  }
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate'
  }
  use {
    'kyazdani42/nvim-tree.lua',
    requires = { 'kyazdani42/nvim-web-devicons' }
  }
  use 'kdheepak/lazygit.nvim'
  use {'neoclide/coc.nvim', branch = 'release'}
  use 'windwp/nvim-autopairs'
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-cmdline'
  use 'L3MON4D3/LuaSnip'
  use 'saadparwaiz1/cmp_luasnip'

  -- New plugins for enhanced IDE experience
  use 'nvim-lualine/lualine.nvim' -- Status line
  use 'lewis6991/gitsigns.nvim' -- Git integration
  use 'numToStr/Comment.nvim' -- Easy commenting
  use 'folke/which-key.nvim' -- Key binding helper
  use 'akinsho/bufferline.nvim' -- Buffer line
  use "lukas-reineke/indent-blankline.nvim"
  use 'goolord/alpha-nvim' -- Start screen
  use 'folke/trouble.nvim' -- Pretty diagnostics
  use {'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
end)

-- Basic settings
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.softtabstop = 2
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.wo.number = true
vim.wo.relativenumber = true
vim.opt.termguicolors = true
vim.opt.cursorline = true
vim.opt.mouse = 'a'

-- Set leader key
vim.g.mapleader = ' '

-- Mason setup
require('mason').setup()
require('mason-lspconfig').setup({
  ensure_installed = { 'lua_ls', 'pyright', 'rust_analyzer' }
})

-- LSP setup
local lspconfig = require('lspconfig')
local servers = { 'lua_ls', 'pyright', 'rust_analyzer' }
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {}
end

-- Treesitter setup
require('nvim-treesitter.configs').setup {
  ensure_installed = { 'lua', 'python', 'javascript', 'typescript', 'rust' },
  highlight = { enable = true },
  indent = { enable = true }
}

-- Telescope setup
require('telescope').setup {
  extensions = {
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = "smart_case",
    }
  }
}

-- Safely load the fzf extension
pcall(require('telescope').load_extension, 'fzf')

-- nvim-tree setup
require('nvim-tree').setup {
  git = {
    enable = true,
    ignore = false,
    timeout = 500,
  }
}

-- CoC setup
vim.cmd([[
inoremap <silent><expr> <tab> pumvisible() ? "\<C-n>" : "\<tab>"
inoremap <silent><expr> <S-tab> pumvisible() ? "\<C-p>" : "\<C-h>"
]])

-- nvim-autopairs setup
require('nvim-autopairs').setup {}

-- Setup nvim-cmp
local cmp = require('cmp')
local npairs = require('nvim-autopairs.completion.cmp')

cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-y>'] = cmp.mapping.confirm({ select = true }),
    ['<C-e>'] = cmp.mapping.abort(),
  }),
  sources = {
    { name = 'nvim_lsp' },
    { name = 'buffer' },
    { name = 'path' },
    { name = 'luasnip' },
  },
})

cmp.event:on('confirm_done', npairs.on_confirm_done())

-- Lualine setup
require('lualine').setup {
  options = {
    theme = 'auto',
    component_separators = '|',
    section_separators = { left = "", right = "" },
  },
}

-- Gitsigns setup
require('gitsigns').setup()

-- Comment.nvim setup
require('Comment').setup()

-- Which-key setup
require('which-key').setup()

-- Bufferline setup
require('bufferline').setup{}

-- Replace the old indent-blankline setup with this:
require("ibl").setup {
    indent = {
        char = "│",
        tab_char = "│",
    },
    scope = { enabled = false },
    exclude = {
        filetypes = {
            "help",
            "alpha",
            "dashboard",
            "neo-tree",
            "Trouble",
            "lazy",
            "mason",
            "notify",
            "toggleterm",
            "lazyterm",
        },
    },
}

-- Trouble setup
require('trouble').setup {}

-- Keybindings
local opts = { noremap = true, silent = true }

-- Telescope
vim.api.nvim_set_keymap('n', '<leader>ff', ':Telescope find_files<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>fg', ':Telescope live_grep<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>fb', ':Telescope buffers<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>fh', ':Telescope help_tags<CR>', opts)

-- nvim-tree
vim.api.nvim_set_keymap('n', '<leader>e', ':NvimTreeToggle<CR>', opts)

-- LazyGit
vim.api.nvim_set_keymap('n', '<leader>lg', ':LazyGit<CR>', opts)

-- Trouble
vim.api.nvim_set_keymap("n", "<leader>xx", "<cmd>Trouble<cr>", opts)
vim.api.nvim_set_keymap("n", "<leader>xw", "<cmd>Trouble workspace_diagnostics<cr>", opts)
vim.api.nvim_set_keymap("n", "<leader>xd", "<cmd>Trouble document_diagnostics<cr>", opts)

-- Bufferline
vim.api.nvim_set_keymap('n', '<TAB>', ':BufferLineCycleNext<CR>', opts)
vim.api.nvim_set_keymap('n', '<S-TAB>', ':BufferLineCyclePrev<CR>', opts)

-- LSP
vim.api.nvim_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
vim.api.nvim_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
vim.api.nvim_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
vim.api.nvim_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
vim.api.nvim_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
vim.api.nvim_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)

-- Set transparent background
vim.api.nvim_set_hl(0, "Normal", { bg = "NONE", ctermbg = "NONE" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE", ctermbg = "NONE" })

      '';
    };

    home-manager.enable = true;

    zoxide = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true; # Enable zoxide for Bash
    };

    lazygit = {
      enable = true;
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true; # Enable fzf for Bash
    };

    thefuck = {
      enable = true;
      enableBashIntegration = true; # Enable thefuck for Bash
    };

    zsh = {

      initExtra = ''
        export WINEPREFIX="$HOME/.wine"
        export NIX_BUILD_SHELL=$(which zsh)
        export DEFAULT_VENDOR=Groq
        export DEFAULT_MODEL=mixtral-8x7b-32768
      '';

      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      shellAliases = {
        iv = '' nvim '';
        vi = "nvim";
        vim = "nvim";
        gsc = '' git add . && git commit -m "$(git diff | fabric -p summarize_git_changes --model phi3.5:latest)" && git push '';
        gac = '' git commit -am "auto commit" && git push '';
        lg = '' lazygit '';
        ld = '' lazydocker'';
        lt = '' tree -L 5'';
        cl = "clear";
        pbcopy='' xclip -selection clipboard '';
        pbpaste='' xclip -selection clipboard -o '';
        gl='' git log --pretty=format:'%h %ad | %s%d [%an]' --graph --date=short '';
        gs='' git status '';
      };

      oh-my-zsh = {
        enable = true;
        plugins = [ "git" "fzf" ];
        theme = "minimal";
      };

    };

    bash = {

      enable = true;

      # Enable bash-completion
      enableCompletion = true;

        # PS1='\[\e[1;34m\]\u\[\e[m\]@\[\e[1;32m\]\h\[\e[m\]:\[\e[1;35m\]\w\[\e[m\]\$ '
      initExtra = ''
        PS1='\[\e[37m\]\u@\h:\w\$ \[\e[m\]'
        bind 'set show-all-if-ambiguous on'
        bind 'set completion-ignore-case on'
        export WINEPREFIX="$HOME/.wine"
        export DEFAULT_VENDOR=Groq
        export DEFAULT_MODEL=mixtral-8x7b-32768
      '';
      
      # Enable programmable completion
      shellAliases = {
        vi = "nvim";
        vim = "nvim";
        gsc = "git add . && git commit -m \"$(git diff | fabric -p summarize_git_changes --model phi3.5:latest)\" && git push";
        gac = "git commit -am \"auto commit\" && git push";
        lg = "lazygit";
        ld = "lazydocker";
        lt = "tree -L 5";
        cl = "clear";
        pbcopy = "xclip -selection clipboard";
        pbpaste = "xclip -selection clipboard -o";
        gl = "git log --pretty=format:'%h %ad | %s%d [%an]' --graph --date=short";
        gs = "git status";
      };
      
    };

  };

  home.stateVersion = "24.05"; # Please read the comment before changing.

  home.file = {
  };

}
