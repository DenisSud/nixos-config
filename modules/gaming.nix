{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.denis.gaming;
in
{
  options.denis.gaming.enable = lib.mkEnableOption "the gaming stack (Steam, ProtonUp-Qt, Lutris, Heroic)";

  config = lib.mkIf cfg.enable {
    # ── Gaming stack ────────────────────────────────────
    # Steam + ProtonUp-Qt (GE-Proton manager) + Lutris + Heroic
    # + performance overlays + gamescope + gamemode.
    programs.steam = {
      enable = true;
      gamescopeSession.enable = true; # Steam "Gamescope" session
    };

    programs.gamemode.enable = true;

    environment.systemPackages = with pkgs; [
      protonup-qt
      lutris
      heroic
      mangohud
      gamescope
    ];
  };
}
