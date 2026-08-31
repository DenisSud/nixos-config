{ pkgs, lib, ... }:

{
  # ── Xray proxy service ────────────────────────────────
  # Reads /etc/xray/config.json (deployed out-of-band).
  # NOTE: config is currently missing on pc, so the service is manual-start
  # only. Deploy the config, then: sudo systemctl start xray
  environment.systemPackages = with pkgs; [
    xray
    proxychains-ng
  ];


  systemd.services.xray = {
    description = "Xray Service";
    after = [ "network.target" ];
    wantedBy = lib.mkForce [ ];
    serviceConfig = {
      ExecStart = "${pkgs.xray}/bin/xray run -c /etc/xray/config.json";
      Restart = "on-failure";
      RestartSec = 30;
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
