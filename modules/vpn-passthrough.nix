# ── Keep declared destinations off a TUN VPN (denis.vpnPassthrough) ───
# Happ's TUN is sing-box with `auto_route`, and auto_route does not just add
# a default route: it installs a policy chain in front of main — its own table
# (2022) and rules from priority 9000 up, the last of which sends every
# destination into that table. A route in `main` is then never consulted, so
# anything that must reach the physical uplink while the tunnel is up (the
# mason/tanya `vpn` sidecars' own VLESS server, the LAN, an SSH client on the
# WAN) has to be a rule of its own above 9000's.
#
# This module owns that rule set: one policy table mirroring `main` minus any
# tunnel device, one rule per destination at `rulePriority`. Rules are static
# and survive the tunnel coming and going; the table is reconciled with the
# uplink on a timer, which is also what re-installs it after a DHCP change.
#
#   vpn-passthrough status    table, rules, exit device per destination
#   vpn-passthrough apply     reconcile by hand (root)
#
# The mechanism is provider-neutral on purpose: it sits outside Happ, so an
# xray or sing-box tunnel gets the same treatment.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.denis.vpnPassthrough;

  package = pkgs.callPackage ../pkgs/vpn-passthrough {
    inherit (cfg) table rulePriority localNetworks destinations;
  };

  # Neither unit needs more than netlink, and neither writes to disk.
  hardening = {
    NoNewPrivileges = true;
    PrivateTmp = true;
    ProtectHome = "tmpfs";
    ProtectSystem = "strict";
  };
in
{
  options.denis.vpnPassthrough = {
    enable = lib.mkEnableOption "the policy routing that keeps declared destinations off a TUN VPN";

    destinations = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "201.51.3.119" "10.88.0.0/16" ];
      description = ''
        Addresses and prefixes that must keep leaving through the physical
        uplink while a tunnel owns the default route: a proxy sidecar's own
        upstream server, a peer on another host's bridge.
      '';
    };

    localNetworks = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Also keep every directly connected prefix (the LAN, the podman
        bridges) off the tunnel. Happ's TUN takes those too, which breaks SSH
        to a LAN peer and the printer while the tunnel is up.
      '';
    };

    table = lib.mkOption {
      type = lib.types.int;
      default = 1090;
      description = "Policy table that mirrors the main table minus tunnels.";
    };

    rulePriority = lib.mkOption {
      type = lib.types.int;
      default = 1000;
      description = "Preference of the per-destination rules (must be below sing-box's 9000).";
    };

    interval = lib.mkOption {
      type = lib.types.str;
      default = "30s";
      description = "How often the mirror is reconciled with the physical uplink.";
    };

    guard = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Run the health check that fails while a destination is routed into the tunnel.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ package ];

    assertions = [
      {
        assertion = cfg.rulePriority > 0 && cfg.rulePriority < 9000;
        message = ''
          denis.vpnPassthrough.rulePriority must stay below 9000: sing-box (Happ's
          TUN) installs its catch-all from 9000 up, and a rule behind it never runs.
        '';
      }
      {
        assertion = cfg.table != 2022;
        message = "denis.vpnPassthrough.table must not be 2022, which sing-box uses.";
      }
    ] ++ map (dest: {
      assertion =
        builtins.match "([0-9]{1,3}\\.){3}[0-9]{1,3}(/[0-9]{1,2})?" dest != null
        || builtins.match "[0-9a-fA-F:]+(/[0-9]{1,3})?" dest != null;
      message = "denis.vpnPassthrough.destinations: '${dest}' is not an address or prefix.";
    }) cfg.destinations;

    systemd.services.vpn-passthrough = {
      description = "Mirror the main routing table minus tunnels for the passthrough destinations";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = hardening // {
        Type = "oneshot";
        ExecStart = "${package}/bin/vpn-passthrough apply";
        CapabilityBoundingSet = [ "CAP_NET_ADMIN" ];
      };
    };

    # The tunnel's own rules never change ours, so nothing has to run when it
    # comes up; the table only follows the uplink (DHCP renew, a cable, wifi).
    systemd.timers.vpn-passthrough = {
      description = "Reconcile the passthrough table with the uplink";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "10s";
        OnUnitActiveSec = cfg.interval;
        AccuracySec = "1s";
      };
    };

    systemd.services.vpn-passthrough-guard = lib.mkIf cfg.guard {
      description = "Fail while a passthrough destination is routed into the tunnel";
      after = [ "vpn-passthrough.service" ];
      serviceConfig = hardening // {
        Type = "oneshot";
        ExecStart = "${package}/bin/vpn-passthrough guard";
      };
    };

    # A failed unit is the alarm: `systemctl --failed`, and one line per
    # destination in the journal naming where it went instead.
    systemd.timers.vpn-passthrough-guard = lib.mkIf cfg.guard {
      description = "Check the passthrough destinations once a minute";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "1min";
        OnUnitActiveSec = "1min";
        AccuracySec = "5s";
      };
    };
  };
}
