{ pkgs, lib, ... }:

{
  # ── Common services ───────────────────────────────────
  services = {
    openssh.enable = true;
    flatpak.enable = true;
  };

  security.polkit.enable = true;

  # ── AppImage support ──────────────────────────────────
  programs.appimage = {
    enable = true;
    binfmt = true;
    package = pkgs.appimage-run.override {
      extraPkgs = pkgs: [ pkgs.libepoxy ];
    };
  };

  # ── nix-index — replaces command-not-found with a fast
  # `nix-locate`-backed helper. Tells you which package
  # provides a missing command.
  programs.nix-index = {
    enable = true;
    enableBashIntegration = false;
    enableFishIntegration = true;
    enableZshIntegration = false;
  };
}
