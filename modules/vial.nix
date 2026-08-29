{ pkgs, ... }:
{
  # ── Vial: live keyboard configurator ─────────────────────
  # Requirements for Vial to work on Linux:
  #   1. The GUI itself — `vial` (AppImage wrapper) in modules/user.nix
  #   2. udev rules that let your user open the keyboard's
  #      /dev/hidraw nodes (this file) — without them Vial
  #      starts but reports "no device found"
  #   3. Firmware with Vial support flashed on the keyboard —
  #      the native/derived board's serial carries the marker
  #      `vial:f64c2b3c` (verify: ls /dev/input/by-id/)
  #
  # The rule below is Vial's official one: it matches on the
  # magic serial every Vial firmware exposes, so any Vial
  # keyboard works without vendor/product pinning.
  # 60- prefix keeps it before udev's 73-seat-late.rules, which
  # matters for the `uaccess` tag to take effect.
  services.udev.packages = [
    (pkgs.writeTextFile {
      name = "vial-udev-rules";
      text = ''
        KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
      '';
      destination = "/etc/udev/rules.d/60-vial.rules";
    })
  ];
}