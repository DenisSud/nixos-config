# ── Parakeet v3 voice typing (IBus engine + GNOME indicator) ─────────
# `denis.voiceTyping.enable` installs:
#   - the `parakeet` IBus engine (NVIDIA parakeet-tdt-0.6b-v3, int8 ONNX,
#     via sherpa-onnx; CPU inference, no network after the build)
#   - a GNOME Shell extension showing the floating waveform pill
#   - a per-user service that installs the GNOME keybinding and enables
#     the extension at login
#
# How it fits together:
#   hotkey -> `parakeet-typing toggle` -> `ibus engine parakeet`
#   -> engine starts pw-record + streams a preedit into the focused field
#   -> VAD endpoint (or a second hotkey press) -> final decode + commit.
# The engine is added to IBUS_COMPONENT_PATH through
# `i18n.inputMethod.ibus.engines`, because nixpkgs' ibus-with-plugins wrapper
# pins that variable to its own merged component directory.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkIf
    mkEnableOption
    mkOption
    types
    ;

  cfg = config.denis.voiceTyping;

  parakeet = pkgs.callPackage ../pkgs/parakeet-typing { };
  indicator = pkgs.callPackage ../pkgs/parakeet-indicator { };
  indicatorUuid = "parakeet-indicator@denis";

  setup = pkgs.writeShellScript "parakeet-typing-setup" ''
    exec ${parakeet}/bin/parakeet-typing setup --quiet \
      --binding ${lib.escapeShellArg cfg.keybinding} \
      --extension ${lib.escapeShellArg indicatorUuid}
  '';
in
{
  options.denis.voiceTyping = {
    enable = mkEnableOption "Parakeet v3 voice typing (IBus engine + GNOME indicator)";

    keybinding = mkOption {
      type = types.str;
      default = "<Super><Alt>v";
      example = "<Super><Shift>d";
      description = ''
        GNOME keybinding that starts/stops dictation. The service installs
        this as a custom shortcut (`org.gnome.settings-daemon.plugins.media-keys`)
        at login, so changing it here and rebuilding is enough.
      '';
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      parakeet
      indicator
    ];

    # ibus-with-plugins merges the package's share/ibus/component into its
    # buildEnv, which is what IBUS_COMPONENT_PATH points at (the user component
    # dir is compiled out of IBus and the wrapper overrides the env var).
    i18n.inputMethod.ibus.engines = [ parakeet ];

    # GNOME has no declarative keybinding/extension-enable story that survives
    # user dconf, so a small oneshot at login reconciles both. It is idempotent
    # and also updates the command path after every rebuild.
    systemd.user.services.parakeet-typing-setup = {
      description = "Install Parakeet dictation keybinding and indicator";
      wantedBy = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = setup;
        RemainAfterExit = true;
      };
    };
  };
}
