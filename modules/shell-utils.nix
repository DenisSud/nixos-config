{
  inputs,
  pkgs,
  ...
}:

{
  # ── Shell / system utilities ──────────────────────────
  environment.systemPackages = with pkgs; [
    # Custom: `rip` from flake input
    inputs.rip.packages.${pkgs.system}.default

    # Proxy
    xray
    proxychains-ng

    # Encryption (secrets management)
    age

    # System essentials
    pi-coding-agent
    gh
    ntfs3g
    lsof
    corefonts
    ffmpeg
    btop-cuda
    git
    git-lfs
    wget
    curl
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
    # pi = "npx @mariozechner/pi-coding-agent";
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
