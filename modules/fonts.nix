{ pkgs, ... }:

{
  # ── Fonts ─────────────────────────────────────────────
  fonts = {
    packages = with pkgs; [
      inter
      nerd-fonts.jetbrains-mono
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "JetBrainsMono Nerd Font Mono" ];
        sansSerif = [ "Inter" ];
        serif = [ "Inter" ];
      };
      cache32Bit = true;
      hinting = {
        enable = true;
        style = "slight";
      };
    };
  };
}
