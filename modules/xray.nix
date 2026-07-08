{ pkgs, ... }:

{
  # ── Xray proxy service ────────────────────────────────
  # Reads /etc/xray/config.json (deployed out-of-band).
  systemd.services.xray = {
    description = "Xray Service";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.xray}/bin/xray run -c /etc/xray/config.json";
      Restart = "always";
      User = "nobody";
      CapabilityBoundingSet = [
        "CAP_NET_ADMIN"
        "CAP_NET_BIND_SERVICE"
      ];
      AmbientCapabilities = [
        "CAP_NET_ADMIN"
        "CAP_NET_BIND_SERVICE"
      ];
      NoNewPrivileges = true;
    };
  };
}
