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
    # gtk2 is marked broken upstream (removed before NixOS 27.05,
    # nixpkgs#410814) and lutris still pulls it in. Warn instead of
    # failing evaluation; drop this once lutris migrates to gtk3 or is
    # removed from this module.
    nixpkgs.config.problems.handlers."gtk+".broken = "warn";

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
