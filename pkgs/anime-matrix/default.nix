# `anime-matrix` — the AniMe Matrix lid helper installed by
# modules/asus.nix (denis.asus.animeMatrix.enable).
#
# The script itself is anime-matrix.sh; this expression only pins the two
# paths it needs (asusctl's bundled gifs and a font for `anime-matrix text`)
# and the tools it shells out to.
{
  pkgs,
  asusGifs ? "${pkgs.asusctl}/share/asusd/anime/asus",
}:

pkgs.writeShellApplication {
  name = "anime-matrix";

  runtimeInputs = with pkgs; [
    asusctl # asusctl anime <image|gif>
    ffmpeg # probe, scale, dither, drawtext
    systemd # systemctl --user for the replay unit
  ];

  text = ''
    ASUS_GIFS=${asusGifs}
    FONT=${pkgs.dejavu_fonts}/share/fonts/truetype/DejaVuSans-Bold.ttf
  ''
  + builtins.readFile ./anime-matrix.sh;
}
