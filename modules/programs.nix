{
  # ── System-wide programs ──────────────────────────────
  programs = {
    mtr.enable = true;

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    fish.enable = true;    # keep during transition; remove in zsh cleanup
    zsh = {
      enable = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
      histSize = 100000;
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
