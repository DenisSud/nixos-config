{
  # ── Bootloader ────────────────────────────────────────
  # systemd-boot on EFI. Per-host kernel packages are set in
  # the host file (hosts/pc.nix, hosts/g14.nix).
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };
}
