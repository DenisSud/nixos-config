# ── PineconeMC (formerly ElyPrismLauncher) ────────────────────────────
# Minecraft launcher fork of PrismLauncher with Ely.by accounts and
# offline mode without a Microsoft account. Not in nixpkgs, so the
# upstream AppImage is repackaged here: appimageTools extracts it and
# rewrites the bundled Qt libraries to point at the nixpkgs ones.
#
# Bump: change version + fetch the new
#   PineconeMC-Linux-x86_64.AppImage
# and refresh `hash` with `nix store prefetch-file --json <url>`.
{
  lib,
  appimageTools,
  fetchurl,
  pname ? "pineconemc",
  version ? "11.1.2",
}:

let
  src = fetchurl {
    url = "https://github.com/ElyPrismLauncher/Launcher/releases/download/${version}/PineconeMC-Linux-x86_64.AppImage";
    hash = "sha256-BoEptHLadljdd5GSUM+4jzjitDplq5IjngtacmupRE0=";
  };

  # Upstream still ships under its old name, so the desktop file and icon
  # are io.github.elyprismlauncher.ElyPrismLauncher.*
  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };

  desktopItem = "io.github.elyprismlauncher.ElyPrismLauncher.desktop";
  iconFile = "io.github.elyprismlauncher.ElyPrismLauncher.png";
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm444 ${appimageContents}/${desktopItem} $out/share/applications/${pname}.desktop
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace "Exec=elyprismlauncher" "Exec=${pname}" \
      --replace "Icon=io.github.elyprismlauncher.ElyPrismLauncher" "Icon=${pname}"
    install -Dm644 ${appimageContents}/${iconFile} $out/share/icons/hicolor/256x256/apps/${pname}.png
  '';

  meta = {
    description = "Minecraft launcher fork of PrismLauncher with Ely.by and offline account support (formerly ElyPrismLauncher)";
    homepage = "https://elyprismlauncher.github.io/";
    license = lib.licenses.gpl3Plus;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = pname;
  };
}
