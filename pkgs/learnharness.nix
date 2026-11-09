# LearnHarness desktop (AGPL-3.0-only), repackaged for NixOS from the
# upstream .deb. An agent harness for learning: adaptive teaching, practice
# sessions and a persistent knowledge graph.
#
# Shape of the package (verified against the 0.5.0 .deb):
#   - opt/LearnHarness is a full bundled Electron 44 runtime whose only job
#     is to spawn the real app: resources/server/standalone/server.js, a
#     Next.js standalone build shipped UNPACKED next to resources/app.asar
#     (the asar holds just the shell). The shell spawns the server with
#     ELECTRON_RUN_AS_NODE=1, so the bundled Electron MUST stay in place —
#     substituting nixpkgs' electron would leave process.resourcesPath
#     pointing at the wrong tree and the server would never be found.
#   - All mutable state lives outside the store, under userData:
#     ~/.config/LearnHarness/{auth.json,data}. The server's own records
#     (chats/*.json, graph/*.jsonl) live in that data dir.
#   - Native code is three .node modules (resvg, napi-rs canvas, sharp) plus
#     sharp's prebuilt libvips; autoPatchelfHook covers them. libvips ships
#     self-contained (only libstdc++/libc), so it needs no extra inputs.
#
# Sandbox: the .deb's postinst chmods chrome-sandbox 4755 only on kernels
# without user namespaces. NixOS has them, so the helper stays 0755 and
# Chromium uses the namespace sandbox — no setuid, no --no-sandbox.
#
# Updates: the in-app updater (electron-updater, deb strategy) cannot write
# to the store and its dpkg install will fail. Updates come from bumping
# `version` + `hash` here and switching the system; the app's own update
# banner is expected to stay ineffective.
#
# Bumping: set `version`, replace `hash` with `nix hash file
# LearnHarness-<version>-amd64.deb`, rebuild, and confirm the layout under
# opt/LearnHarness still matches (bin/learnharness, resources/{app.asar,
# server/standalone/server.js}).
{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  makeWrapper,
  makeDesktopItem,
  copyDesktopItems,
  wrapGAppsHook3,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  cairo,
  cups,
  dbus,
  expat,
  glib,
  gtk3,
  libgbm,
  libglvnd,
  libnotify,
  libsecret,
  libx11,
  libxcb,
  libxcomposite,
  libxcursor,
  libxdamage,
  libxext,
  libxfixes,
  libxi,
  libxkbcommon,
  libxrandr,
  libxrender,
  libxshmfence,
  libxtst,
  mesa,
  nspr,
  nss,
  pango,
  systemd,
  util-linux,
  xdg-utils,
  xorg,
}:

stdenv.mkDerivation rec {
  pname = "learnharness";
  version = "0.5.0";

  src = fetchurl {
    url = "https://github.com/amosblomqvist/learnharness/releases/download/v${version}/LearnHarness-${version}-amd64.deb";
    hash = "sha256-nR7nwQXvnMvMoH+M2nQlureALGufANzvcTol0k4FIIQ=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
    wrapGAppsHook3
    copyDesktopItems
  ];

  buildInputs = [
    (lib.getLib stdenv.cc.cc)
    alsa-lib
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    dbus
    expat
    glib
    gtk3
    libgbm
    libglvnd
    libnotify
    libsecret
    libxkbcommon
    mesa
    nspr
    nss
    pango
    systemd
    util-linux
    libx11
    libxcb
    libxcomposite
    libxcursor
    libxdamage
    libxext
    libxfixes
    libxi
    libxrandr
    libxrender
    libxshmfence
    libxtst
  ];

  dontUnpack = true;
  dontWrapGApps = true;

  desktopItems = [
    (makeDesktopItem {
      name = "learnharness";
      desktopName = "LearnHarness";
      exec = "learnharness %U";
      icon = "learnharness";
      comment = "An agent harness for learning: adaptive teaching, practice, and a persistent knowledge graph";
      categories = [ "Education" ];
      startupWMClass = "learnharness";
    })
  ];

  installPhase = ''
    runHook preInstall

    dpkg -x $src .
    mkdir -p $out/lib $out/bin
    cp -r opt/LearnHarness $out/lib/learnharness

    # Namespace sandbox is enough here (user namespaces enabled); a setuid
    # helper would be stripped from the store anyway.
    chmod 0755 $out/lib/learnharness/chrome-sandbox

    install -Dm444 usr/share/icons/hicolor/512x512/apps/learnharness.png \
      $out/share/icons/hicolor/512x512/apps/learnharness.png

    # NIXOS_OZONE_WL + a Wayland session opts into native Wayland (same
    # gate nixpkgs' obsidian uses); otherwise Electron picks XWayland.
    makeWrapper $out/lib/learnharness/learnharness $out/bin/learnharness \
      "''${gappsWrapperArgs[@]}" \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform=wayland --enable-wayland-ime --wayland-text-input-version=3}}" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ libglvnd ]}:/run/opengl-driver/lib" \
      --prefix PATH : "${lib.makeBinPath [ xdg-utils ]}"

    runHook postInstall
  '';

  meta = {
    description = "Agent harness for learning: adaptive teaching, practice, and a persistent knowledge graph";
    homepage = "https://learnharness.ai";
    downloadPage = "https://github.com/amosblomqvist/learnharness/releases";
    mainProgram = "learnharness";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    license = lib.licenses.agpl3Only;
    platforms = [ "x86_64-linux" ];
  };
}
