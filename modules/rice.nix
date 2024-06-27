{config, pkgs, ...}:
{
  stylix = {
    base16Scheme = "${pkgs.base16-schemes}/share/themes/black-metal-nile.yaml";
    image = /home/denis/Pictures/space_person.jpg;

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
