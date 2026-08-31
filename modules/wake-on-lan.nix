# ── Wake-on-LAN (magic packet on eno1) ────────────────────
# PC is woken remotely via the always-on RPi:
#   ssh pi.wan 'wakeonlan 60:cf:84:dc:80:22'
#
# NIC: Realtek RTL8125 (r8169), MAC 60:cf:84:dc:80:22.
# NetworkManager's global `ethernet.wake-on-lan=magic` default
# alone was not reflected on the NIC, so WOL is armed explicitly:
#   - at boot,
#   - right before every suspend (sleep.target).
# Also enabled: PCIe wake on GPP2 — the root port the NIC hangs
# under (00:02.1 → ... → 08:00.0) — already `enabled` via sysfs
# (verified: /sys/devices/pci0000:00/0000:00:02.1/power/wakeup).
{
  pkgs,
  lib,
  ...
}:

{
  systemd.services.wake-on-lan = {
    description = "Arm Wake-on-LAN (magic packet) on eno1";
    wantedBy = [ "multi-user.target" "sleep.target" ];
    before = [ "sleep.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.ethtool}/bin/ethtool -s eno1 wol g";
    };
  };
}
