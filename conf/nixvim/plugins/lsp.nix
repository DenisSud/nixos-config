# plugins/lsp.nix
{
  programs.nixvim = {
    plugins = {
      lsp = {
        enable = true;
        servers = {
          # Language servers
          lua-ls.enable = true;        # Lua
          nil_ls.enable = true;        # Nix
          rust-analyzer.enable = true;  # Rust
          pyright.enable = true;       # Python
          tsserver.enable = true;      # TypeScript/JavaScript
        };

        keymaps = {
          diagnostic = {
            "<leader>j" = "goto_next";
            "<leader>k" = "goto_prev";
          };
          lspBuf = {
            K = "hover";
            gd = "definition";
            gi = "implementation";
            gr = "references";
            "<leader>r" = "rename";
            "<leader>f" = "format";
            "<leader>ca" = "code_action";
          };
        };
      };

      # Autocompletion
      nvim-cmp = {
        enable = true;
        autoEnableSources = true;
        sources = [
          {name = "nvim_lsp";}
          {name = "path";}
          {name = "buffer";}
          {name = "luasnip";}
        ];

        mapping = {
          "<CR>" = "cmp.mapping.confirm({ select = true })";
          "<Tab>" = {
            action = ''
              function(fallback)
                if cmp.visible() then
                  cmp.select_next_item()
                else
                  fallback()
                end
              end
            '';
            modes = ["i" "s"];
          };
          "<S-Tab>" = {
            action = ''
              function(fallback)
                if cmp.visible() then
                  cmp.select_prev_item()
                else
                  fallback()
                end
              end
            '';
            modes = ["i" "s"];
          };
        };
      };

      # Snippets
      luasnip.enable = true;

      # LSP status updates
      fidget.enable = true;
    };
  };
}
