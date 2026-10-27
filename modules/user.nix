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
    shell = pkgs.zsh;
    packages = with pkgs; [
      fastfetch
      onefetch
      fetch
      sqlite
      foliate
      unzip
      dust
      ripgrep
      starship
      obsidian
      wl-clipboard
      zoxide
      wayshot
      gnome-tweaks
      impression
      # Screen recording / streaming. The GoPro does not need it — gopro-webcam
      # feeds /dev/video42 (pc) and any app can take that directly. OBS's own
      # "Start Virtual Camera" wants a v4l2loopback device too and will fight
      # gopro-webcam for video_nr=42; leave it off while streaming.
      obs-studio
      anki
      vial
      ghostty
      texstudio
      qbittorrent
      fzf

      # Browser automation for the pi agent (skill: agent-browser);
      # chromium is its CDP browser, found on PATH.
      agent-browser
      chromium

      # GNOME extensions (declarative install)
      gnomeExtensions.caffeine
      gnomeExtensions.clipboard-indicator
      gnomeExtensions.blur-my-shell
      gnomeExtensions.gsconnect
    ];
  };
}
