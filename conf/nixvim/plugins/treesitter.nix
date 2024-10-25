# plugins/treesitter.nix
{
  programs.nixvim = {
    plugins.treesitter = {
      enable = true;

      # Install all grammar packages for common languages
      ensureInstalled = [
        "bash"
        "c"
        "html"
        "javascript"
        "json"
        "lua"
        "markdown"
        "nix"
        "python"
        "rust"
        "tsx"
        "typescript"
        "vim"
        "yaml"
      ];

      # Auto install grammars
      installAllGrammars = true;

      # Automatically indent based on treesitter
      indent = true;

      incrementalSelection = {
        enable = true;
        keymaps = {
          initSelection = "<C-space>";
          nodeIncremental = "<C-space>";
          nodeDecremental = "<bs>";
        };
      };
    };
  };
}
