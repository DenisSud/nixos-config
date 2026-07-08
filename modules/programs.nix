{
  # ── System-wide programs ──────────────────────────────
  programs = {
    mtr.enable = true;

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    fish.enable = true;

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
