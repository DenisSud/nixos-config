{ pkgs, ... }:

{
  # ── Development toolchain ─────────────────────────────
  # Languages, LSPs, formatters, tree-sitter, build tools.
  environment.systemPackages = with pkgs; [
    # Languages / runtimes
    nodejs
    gcc
    pkg-config

    # LSP servers
    vtsls
    vscode-langservers-extracted
    emmet-language-server
    gopls
    rust-analyzer
    lua-language-server
    basedpyright
    nil

    # Formatters
    nixfmt
    stylua
    prettierd
    gofumpt
    gotools
    rustfmt
    isort
    black

    # Tree-sitter
    tree-sitter

    # Development environments
    devenv
  ];
}
