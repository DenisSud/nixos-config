# ── tmux: persistent terminal sessions for remote (phone/tablet) access ──
#
# SSH in from Termux (Samsung phone/tablet) → fish auto-attaches to the
# session "main". Disconnects leave everything running; reconnecting
# (from any device) re-attaches to the same session.
#
# tmux over zellij: battle-tested with mobile SSH clients, and
# `new-session -A -s main` gives the exact attach-or-create semantic.
{
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
  #   - status is-interactive → never hijack scp/rsync/git-over-ssh
  #   - SSH_TTY               → only real SSH logins, not local terminals
  #   - TMUX                  → no nesting when SSHing from inside tmux
  # `new-session -A` attaches to session "main" if it exists, else creates it.
  programs.fish.interactiveShellInit = ''
    if status is-interactive; and set -q SSH_TTY; and not set -q TMUX
        exec tmux new-session -A -s main
    end
  '';
}
