# ── Happ proxy desktop client (+ happd TUN daemon) ────────────────────
# `denis.happ.enable` installs the Happ GUI and runs its privileged
# `happd` daemon, which the client uses for TUN mode (`sing-box` /
# `tun2proxy` run as root). Proxy/SOCKS mode works without the daemon.
#
# The package is a vendored repackaging of the upstream .deb (see
# ../pkgs/happ.nix); adapted from https://github.com/Rottenfront/happ.nix.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf mkEnableOption mkOption types stringAfter;
  cfg = config.denis.happ;
  happ = pkgs.callPackage ../pkgs/happ.nix {
    inherit (cfg) forceXwayland forceSoftwareRendering;
  };
in
{
  options.denis.happ = {
    enable = mkEnableOption "the Happ proxy desktop client and its background TUN daemon";

    forceXwayland = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Force Happ to run through XWayland (XCB) instead of its bundled Qt6
        Wayland plugins, which are dropped from the package entirely. Works
        around a silent startup crash on wlroots-based Wayland compositors
        (Hyprland, Sway, ...) where the bundled Qt6 Wayland integration is
        incompatible. Not needed on GNOME by default.
      '';
    };

    forceSoftwareRendering = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Force Happ's Qt Quick UI to render in software
        (`QML_SCENE_GRAPH=software`, `LIBGL_ALWAYS_SOFTWARE=1`). Independent
        escape hatch for GPU/driver rendering issues, e.g. blank or broken UI
        on NVIDIA.
      '';
    };
  };

  config = mkIf cfg.enable {
    # Tools Happ and its helper scripts call from the system PATH.
    environment.systemPackages = [
      happ
      pkgs.net-tools
      pkgs.lsb-release
    ];

    # HWID fix. Happ reads its hardware id from Qt's QSysInfo::machineUniqueId(),
    # which on Linux comes from /var/lib/dbus/machine-id. NixOS defaults to
    # dbus-broker, which (unlike the classic dbus-daemon) does not create that
    # file, so the id is empty and the client shows a blank HWID. Linking it to
    # the real /etc/machine-id fixes it.
    systemd.tmpfiles.rules = [
      "L+ /var/lib/dbus/machine-id - - - - /etc/machine-id"
    ];

    # Firewall + TUN module for Happ's TUN mode.
    networking.firewall.checkReversePath = "loose";
    networking.firewall.trustedInterfaces = [ "tun0" ];
    boot.kernelModules = [ "tun" ];

    # Happ hard-codes /opt/happ for its binaries, so we materialise the
    # immutable Nix store tree there. The copy runs only when the package
    # changes, keeping everyday rebuilds fast. Happ's actual runtime state
    # (routing, generated core configs) lives per-user under ~/.config/Happ,
    # not under /opt/happ, so the materialised tree only needs to be
    # readable/executable, never writable -- making it world-writable would
    # let any unprivileged local user replace the happd binary that systemd
    # runs as root below.
    system.activationScripts.happ-opt = stringAfter [ "stdio" ] ''
      stamp=/opt/happ/.nix-store-path
      if [ "$(cat "$stamp" 2>/dev/null)" != "${happ}" ]; then
        rm -rf /opt/happ
        mkdir -p /opt/happ
        cp -r ${happ}/happ/. /opt/happ/
        chown -R root:root /opt/happ
        chmod -R u=rwX,go=rX /opt/happ
        printf '%s' "${happ}" > "$stamp"
      fi
    '';

    # Privileged daemon that runs the TUN cores (sing-box / tun2proxy) as
    # root. Kept unsandboxed on purpose: systemd sandboxing enables a mount
    # namespace whose machine-id bind-mount fails and breaks TUN mode.
    systemd.services.happd = {
      description = "Happ Process Control Daemon";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      # ExecStart is a fixed /opt/happ path rather than a Nix store path, so
      # switch-to-configuration can't see a package bump from the unit alone;
      # without this, happd would keep running the old binary after an upgrade.
      restartTriggers = [ happ ];

      path = with pkgs; [
        iproute2
        iptables
        procps
        net-tools
      ];

      serviceConfig = {
        Type = "simple";
        User = "root";
        Group = "root";
        ExecStart = "/opt/happ/bin/happd";
        # `always`, not `on-failure`: the daemon exits cleanly on purpose
        # when a newer client connects so systemd re-execs the upgraded
        # binary (upstream's own happd.service does the same). An explicit
        # `systemctl stop` still stops the unit for good.
        Restart = "always";
        RestartSec = "5s";
        TimeoutStopSec = "10s";
        KillMode = "mixed";
        KillSignal = "SIGTERM";
      };
    };
  };
}
