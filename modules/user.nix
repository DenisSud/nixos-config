{
  pkgs,
  lib,
  config,
  ...
}:

{
  # ── User: denis ───────────────────────────────────────
  # Base packages live here. Host-specific user packages
  # (e.g. libreoffice on PC, asusctl on g14) are added in
  # the host file via:
  #   users.users.denis.packages = with pkgs; [ ... ];
  users.users.denis = {
    isNormalUser = true;
    description = "denis";
    extraGroups = [
      "networkmanager"
      "wheel"
      "i2c"
      "seat"
    ]
    # Only add to `docker` group on hosts where Docker is actually
    # enabled — the group doesn't exist otherwise and the build
    # would fail trying to add the user to a non-existent group.
    ++ lib.optional config.virtualisation.docker.enable "docker";
    shell = pkgs.fish;
    packages = with pkgs; [
      fastfetch
      onefetch
      codex
      unzip
      dust
      ripgrep
      starship
      obsidian
      qbittorrent
      telegram-desktop
      wl-clipboard
      zoxide
      gnome-tweaks
      impression
      anki
      vial
      ghostty
      fzf
      direnv
      nix-direnv

      # GNOME extensions (declarative install)
      gnomeExtensions.caffeine
      gnomeExtensions.clipboard-indicator
      gnomeExtensions.blur-my-shell
      gnomeExtensions.gsconnect
    ];
  };
}
