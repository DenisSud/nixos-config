# agent-desktop (vercel-labs): computer use for AI agents over the OS
# accessibility tree. On Linux that is AT-SPI over D-Bus, so an agent reads
# a JSON tree with a ref per element and acts on refs instead of pixels.
#
# Repackaged from the upstream release tarball: nixpkgs has no expression,
# and the release is a plain dynamically-linked Rust binary (glibc +
# libgcc_s, nothing else) with the platform helper next to it.
#
# Bumping: set `version`, replace `hash` (`nix hash file <tarball>`), build,
# and check the tarball still ships both files — the CLI and
# `agent-desktop-linux-clipboard-owner`, which has to sit beside it for
# `clipboard-set` to work on X11.
{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:

stdenv.mkDerivation rec {
  pname = "agent-desktop";
  version = "1.2.0";

  src = fetchurl {
    url = "https://github.com/vercel-labs/agent-desktop/releases/download/v${version}/agent-desktop-v${version}-x86_64-unknown-linux-gnu.tar.gz";
    hash = "sha256-WRrn9KOEedwEXfl+J0R8DItTBEFzCra5kOJ8gTFir0Q=";
  };

  # The archive holds the two executables at its root, no top-level directory.
  dontUnpack = true;

  nativeBuildInputs = [ autoPatchelfHook ];

  # libgcc_s; glibc comes from the hook's own default.
  buildInputs = [ stdenv.cc.cc.lib ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    tar xzf $src -C $out/bin
    chmod +x $out/bin/agent-desktop $out/bin/agent-desktop-linux-clipboard-owner

    runHook postInstall
  '';

  meta = {
    description = "Computer use for AI agents through the OS accessibility tree";
    homepage = "https://github.com/vercel-labs/agent-desktop";
    license = lib.licenses.asl20;
    platforms = [ "x86_64-linux" ];
    mainProgram = "agent-desktop";
  };
}
