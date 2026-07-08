{ pkgs, ... }:

{
  # ── ASUS Linux stack (g14 only) ───────────────────────
  # Built into nixpkgs directly — no extra flake input needed.
  #
  # `services.asusd`    — the asusd daemon + asusctl CLI.
  #                       Profile switching (Performance / Balanced /
  #                       Silent), fan curves, AniMe matrix, LED keyboard.
  #                       ROG Control Center GUI is included.
  # `services.supergfxd` — dGPU mode switching (Integrated / Hybrid /
  #                       Dedicated). NOTE: supergfxctl is being phased
  #                       out upstream; only keep it if you need vfio
  #                       for VMs or have issues powering off the dGPU.
  services = {
    asusd.enable = true;
    supergfxd.enable = true;
  };

  # Workaround for a known issue where supergfxd can't detect the
  # graphics card without `lspci` in its PATH.
  # See: https://asus-linux.org/guides/nixos
  systemd.services.supergfxd.path = [ pkgs.pciutils ];

  # Explicit CLI packages (asusd module already adds asusctl, this is
  # just to guarantee the binaries are in PATH).
  environment.systemPackages = with pkgs; [
    asusctl
    supergfxctl
  ];
}
