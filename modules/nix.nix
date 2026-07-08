{ pkgs, ... }:

{
  # ── Nix daemon ────────────────────────────────────────
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # ── nh: NixOS helper ──────────────────────────────────
  # `nh os switch` / `nh os boot` from any directory,
  # plus weekly garbage collection of old generations.
  programs.nh = {
    enable = true;
    flake = "/home/denis/nixos-config";
    clean = {
      enable = true;
      dates = "weekly";
    };
  };
}
