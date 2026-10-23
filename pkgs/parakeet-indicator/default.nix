# GNOME Shell extension: floating waveform pill shown while parakeet-typing
# is listening.  Installed system-wide; the parakeet setup service appends
# its UUID to org.gnome.shell enabled-extensions.
{ lib, stdenv }:

stdenv.mkDerivation {
  pname = "gnome-shell-extension-parakeet-indicator";
  version = "0.1.0";

  src = ./.;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    dir="$out/share/gnome-shell/extensions/parakeet-indicator@denis"
    install -d "$dir"
    install -m644 metadata.json extension.js stylesheet.css "$dir/"
    runHook postInstall
  '';

  meta = {
    description = "Floating waveform indicator for parakeet-typing";
    homepage = "https://github.com/DenisSud/nixos-config";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
