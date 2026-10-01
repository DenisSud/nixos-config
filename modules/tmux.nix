# ── tmux: persistent terminal sessions for remote (phone/tablet) access ──
#
# SSH in from Termux (Samsung phone/tablet) → zsh auto-attaches to the
# session "main". Disconnects leave everything running; reconnecting
# (from any device) re-attaches to the same session.
#
# tmux over zellij: battle-tested with mobile SSH clients, and
# `new-session -A -s main` gives the exact attach-or-create semantic.
{
  config,
  lib,
  ...
}:

let
  cfg = config.denis.tmux;
in
{
  options.denis.tmux.enable = lib.mkEnableOption "tmux with SSH auto-attach";

  config = lib.mkIf cfg.enable {
    programs.tmux = {
      enable = true;
      # Fast Esc over SSH — the 500 ms default makes nvim feel laggy.
      escapeTime = 10;
      historyLimit = 50000;
      keyMode = "vi";
      terminal = "screen-256color";
      extraConfig = ''
        # Truecolor passthrough for capable terminals
        set -ga terminal-overrides ',*:Tc'
        # Renumber windows when one is closed
        set -g renumber-windows on
      '';
    };

    # Auto-attach on interactive SSH logins. Guards:
    #   - [[ -o interactive ]]  → never hijack scp/rsync/git-over-ssh
    #   - SSH_TTY               → only real SSH logins, not local terminals
    #   - TMUX                  → no nesting when SSHing from inside tmux
    # `new-session -A` attaches to session "main" if it exists, else creates it.
    programs.zsh.interactiveShellInit = ''
      if [[ -o interactive && -n $SSH_TTY && -z $TMUX ]]; then
        exec tmux new-session -A -s main
      fi
    '';
  };
}
