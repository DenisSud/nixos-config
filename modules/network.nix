{
  # ── Networking ────────────────────────────────────────
  networking = {
    networkmanager.enable = true;
    # enableIPv6 = false;

    # Firewall is re-enabled (was disabled globally before).
    # Each service module that needs an inbound port opens it
    # explicitly via `networking.firewall.allowedTCPPorts`.
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22 # SSH (also auto-opened by services.openssh, kept explicit for clarity)
        2718 # marimo arc-agi-3 notebook (marimo.sudakov.site)
        2719 # marimo public notebooks
      ];
      allowedTCPPortRanges = [
        {
          from = 1714;
          to = 1764;
        } # KDE Connect / GSConnect
      ];
      allowedUDPPortRanges = [
        {
          from = 1714;
          to = 1764;
        } # KDE Connect / GSConnect
      ];
    };
  };
}
