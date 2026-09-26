{
  inputs,
  pkgs,
  ...
}:

{
  # ── Shell / system utilities ──────────────────────────
  environment.systemPackages = with pkgs; [
    # Custom: `rip` from flake input
    inputs.rip.packages.${pkgs.stdenv.hostPlatform.system}.default

    # Encryption (secrets management)
    age

    # Bitwarden CLI bridge (vault stays in the Bitwarden apps; rbw is the
    # programmatic layer used by pi's security extension). pinentry-curses
    # handles the `rbw unlock` master-password prompt in the terminal.
    rbw
    pinentry-curses

    # browser thing for agents
    playwright

    # System essentials
    pi-coding-agent
    gh
    forgejo-cli
    ntfs3g
    lsof
    corefonts
    ffmpeg
    btop-cuda
    git
    git-lfs
    curl
    openssl
    tmux
    zellij
    file
    dig
    iw
    tree
    neovim
    glow
    bat
    jq
    ddcutil
    fd
    eza
    pandoc
  ];

  # ── Shell aliases (apply system-wide) ─────────────────
  environment.shellAliases = {
    vi = "nvim";
    ls = "eza";
    ll = "eza -lbF --git";
    la = "eza -lbhHigUmuSa --git";
    lt = "eza --tree --level=2";
  };

  # ── Session variables ─────────────────────────────────
  environment.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    NIXOS_OZONE_WL = "1";
  };
}
