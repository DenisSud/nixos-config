# ── agent-desktop (denis.agentDesktop.enable) ─────────────────────────
# Computer use for AI agents without screenshots: it reads a desktop app's
# accessibility tree (AT-SPI over D-Bus on Linux) and returns JSON with a
# ref for every element the agent can act on. The agent clicks or types on
# a ref, re-reads the UI, repeats. No model inside — the loop lives in the
# calling agent, the CLI is the hands.
#
#   agent-desktop status                   platform, permissions, surfaces
#   agent-desktop list-apps                what is registered on the bus
#   agent-desktop snapshot --app Files -i  interactive elements, each a ref
#   agent-desktop click @s8f3k2p9:e8       act on a ref from that snapshot
#   agent-desktop skills get desktop       the loop/ref/retry rules, for agents
#
# Refs belong to one snapshot: after a UI change an action answers
# STALE_REF or AMBIGUOUS_TARGET and the agent takes a fresh snapshot. Ref
# actions are semantic AT-SPI calls, so they do not move the pointer or
# steal focus unless --headed is passed.
#
# Linux prerequisites, all already present on a GNOME session: a running
# at-spi-dbus-bus.service (GNOME starts it) and a graphical session — run it
# from a shell inside that session, not over SSH. Wayland clipboard reads
# and writes go through wl-clipboard, which is installed here; window
# control and pointer gestures are X11-only by design.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.denis.agentDesktop;
in
{
  options.denis.agentDesktop.enable = lib.mkEnableOption "agent-desktop (accessibility-tree computer use for AI agents)";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      (pkgs.callPackage ../pkgs/agent-desktop.nix { })
      # The Wayland clipboard leg of clipboard-get/set/clear. X11 uses the
      # agent-desktop-linux-clipboard-owner helper instead, which ships
      # inside the package.
      pkgs.wl-clipboard
    ];
  };
}
