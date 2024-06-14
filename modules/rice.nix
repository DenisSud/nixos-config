{config, pkgs, ...}:
{
  stylix = {
    base16Scheme = "${pkgs.base16-schemes}/share/themes/kanagawa.yaml";
    image = /home/denis/Pictures/dark_guy_1.jpg;

    # cursor.package = pkgs.apple-cursor;

    fonts = {
      serif = {
        package = pkgs.nerdfonts;
        name = "Hack Nerd Font";
      };

      sansSerif = {
        package = pkgs.dejavu_fonts;
        name = "Hack Nerd Font";
      };

      monospace = {
        package = pkgs.dejavu_fonts;
        name = "Hack Nerd Font";
      };

      emoji = {
        package = pkgs.noto-fonts-emoji;
        name = "Hack Nerd Font";
      };
    };

  };
}
