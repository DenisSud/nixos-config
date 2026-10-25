{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.denis.asus;
  animeMatrix = pkgs.callPackage ../pkgs/anime-matrix { };
in
{
  options.denis.asus = {
    enable = lib.mkEnableOption "the ASUS Linux stack (asusd + supergfxd)";

    animeMatrix.enable = lib.mkEnableOption "the AniMe Matrix lid helpers (`anime-matrix`)";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      # ── ASUS Linux stack (g14 only) ───────────────────────
      # Built into nixpkgs directly — no extra flake input needed.
      #
      # `services.asusd`    — the asusd daemon + asusctl CLI.
      #                       Profile switching (Performance / Balanced /
      #                       Silent), fan curves, AniMe matrix, LED keyboard.
      #                       ROG Control Center GUI is included.
      # `services.supergfxd` — dGPU mode switching (Integrated / Hybrid /
      #                       Dedicated). NOTE: supergfxctl is being phased
      #                       out upstream; only keep it if you need vfio
      #                       for VMs or have issues powering off the dGPU.
      services = {
        asusd.enable = true;
        supergfxd.enable = true;
      };

      # Workaround for a known issue where supergfxd can't detect the
      # graphics card without `lspci` in its PATH.
      # See: https://asus-linux.org/guides/nixos
      systemd.services.supergfxd.path = [ pkgs.pciutils ];

      # Explicit CLI packages (asusd module already adds asusctl, this is
      # just to guarantee the binaries are in PATH).
      environment.systemPackages = with pkgs; [
        asusctl
        supergfxctl
      ];
    })

    # ── AniMe Matrix lid display (denis.asus.animeMatrix) ─
    # The GA401 panel is driven through asusd; keep the daemon running (it
    # also owns the fan curves and profile switching) and push frames at it
    # over D-Bus instead of opening the USB device directly, which is what
    # the third-party AniMe apps do.
    #
    # `anime-matrix` renders the source (image / gif / video / text) to the
    # panel's 78x48 aspect with ffmpeg and hands it to `asusctl anime`. The
    # gif loop has to stay in the foreground to keep streaming frames, so it
    # lives in a user service; the last choice is replayed at login.
    (lib.mkIf (cfg.enable && cfg.animeMatrix.enable) {
      environment.systemPackages = [ animeMatrix ];

      systemd.user.services.anime-matrix = {
        description = "AniMe Matrix lid display (replays the saved animation)";
        wantedBy = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${animeMatrix}/bin/anime-matrix _run";
          # A no-op is a clean exit (nothing saved), only a failed write is
          # worth retrying.
          Restart = "on-failure";
          RestartSec = 3;
        };
      };
    })
  ];
}
