return {
  setup = function()
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
  end
}
