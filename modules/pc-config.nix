{ config, pkgs, ... }:

{
  # ── Host Identity ─────────────────────────────────────
  networking.hostName = "pc";

  # ── Kernel ────────────────────────────────────────────
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  # ── NVIDIA (RTX 5070 / Blackwell) ────────────────────
  hardware.nvidia = {
    open = true;
    powerManagement.enable = true; # needed for proper suspend/resume
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  # ── Ollama: expose to LAN ─────────────────────────────
  services.ollama.openFirewall = true;
  services.ollama.enable = true;

  # ── Xray Proxy Service ───────────────────────────────
  systemd.services.xray = {
    description = "Xray Service";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.xray}/bin/xray run -c /etc/xray/config.json";
      Restart = "always";
      User = "nobody";
      CapabilityBoundingSet = [ "CAP_NET_ADMIN" "CAP_NET_BIND_SERVICE" ];
      AmbientCapabilities = [ "CAP_NET_ADMIN" "CAP_NET_BIND_SERVICE" ];
      NoNewPrivileges = true;
    };
  };

  # ── PC-only User Packages ─────────────────────────────
  users.users.denis.packages = with pkgs; [
    gnomeExtensions.control-monitor-brightness-and-volume-with-ddcutil
  ];
}
