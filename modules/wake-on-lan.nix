# ── Wake-on-LAN / Wake-on-WLAN (magic-packet arming) ──────
# Arms magic-packet wake on the configured interfaces so the
# machine can be woken remotely after suspend.
#
#   pc  — wired (ethernetInterface): Realtek RTL8125 (eno1,
#         r8169). NM's global `ethernet.wake-on-lan=magic`
#         alone was not reflected on the NIC, so WOL is armed
#         explicitly: at boot, and right before every suspend
#         (sleep.target). PCIe wake on GPP2 — the root port the
#         NIC hangs under — is already `enabled` via sysfs
#         (/sys/devices/pci0000:00/0000:00:02.1/power/wakeup).
#
#   g14 — wireless (wifiPhy): MediaTek MT7921 (wlp2s0,
#         mt7921e). No wired NIC, so only WoWLAN applies —
#         magic-packet armed via iw right before each suspend.
#
# Sender side (any host on the LAN, e.g. the always-on RPi):
#   wakeonlan 60:cf:84:dc:80:22   # pc
#   wakeonlan 34:6f:24:a4:0a:57   # g14
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.denis.wakeOnLan;
in
{
  options.denis.wakeOnLan = {
    enable = lib.mkEnableOption "Wake-on-LAN arming";

    ethernetInterface = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "eno1";
      description = "Ethernet interface to arm for wake-on-LAN (via ethtool).";
    };

    wifiPhy = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "phy0";
      description = "Wireless PHY to arm for wake-on-WLAN magic packets (via iw).";
    };
  };

  config = lib.mkIf cfg.enable {
    # NetworkManager applies this on every ethernet activation,
    # so WOL survives reconnects and suspend/resume cycles.
    networking.networkmanager.connectionConfig = lib.optionalAttrs (cfg.ethernetInterface != null) {
      "ethernet.wake-on-lan" = "magic";
    };

    systemd.services.wake-on-lan = lib.mkIf (cfg.ethernetInterface != null) {
      description = "Arm Wake-on-LAN (magic packet) on ${cfg.ethernetInterface}";
      wantedBy = [
        "multi-user.target"
        "sleep.target"
      ];
      before = [ "sleep.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.ethtool}/bin/ethtool -s ${cfg.ethernetInterface} wol g";
      };
    };

    systemd.services.wake-on-wlan = lib.mkIf (cfg.wifiPhy != null) {
      description = "Arm Wake-on-WLAN (magic packet) on ${cfg.wifiPhy}";
      # Suspends are the only time WoWLAN matters — arming right
      # before sleep.target avoids racing NetworkManager at boot.
      wantedBy = [ "sleep.target" ];
      before = [ "sleep.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.iw}/bin/iw phy ${cfg.wifiPhy} wowlan enable magic-packet";
      };
    };
  };
}
