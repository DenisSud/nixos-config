{
  # ── Desktop: GNOME ────────────────────────────────────
  services = {
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    xserver.xkb = {
      layout = "us";
      variant = "";
    };
  };
}
