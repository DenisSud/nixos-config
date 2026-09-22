{
  # ── Networking ────────────────────────────────────────
  networking = {
    networkmanager.enable = true;
    # enableIPv6 = false;

    # Each service module that needs an inbound port opens it
    # explicitly via `networking.firewall.allowedTCPPorts`.
    # `enable` itself is set per host in hosts/*.nix (g14: on, pc: off).
    firewall = {
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
