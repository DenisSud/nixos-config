{
  # ── Networking ────────────────────────────────────────
  networking = {
    networkmanager.enable = true;

    # Firewall is re-enabled (was disabled globally before).
    # Each service module that needs an inbound port opens it
    # explicitly via `networking.firewall.allowedTCPPorts`.
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22 # SSH (also auto-opened by services.openssh, kept explicit for clarity)
      ];
      allowedTCPPortRanges = [
        { from = 1714; to = 1764; } # KDE Connect / GSConnect
      ];
      allowedUDPPortRanges = [
        { from = 1714; to = 1764; } # KDE Connect / GSConnect
      ];
    };
  };
}
