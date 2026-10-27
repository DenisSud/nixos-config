# ── GoPro as a webcam (denis.goproWebcam.enable) ──────────────────────
# GoPro HERO8 and later can stream over USB in "GoPro Connect" mode: the
# camera becomes a USB ethernet adapter, hands the host an address, and
# serves MPEG-TS/H.264 over UDP 8554 after one HTTP request. A v4l2loopback
# device is where that lands, so OBS, Zoom, Meet and the browser camera
# picker all see a normal 1080p30 webcam called "GoPro".
#
# No capture card and no Media Mod. (HDMI out does need the Media Mod on a
# HERO9 — only relevant if the USB route ever stops working.)
#
#   gopro-webcam           start streaming into /dev/video42
#   gopro-webcam status    interface, virtual device, format
#   gopro-webcam stop      tell the camera to leave webcam mode
#
# The camera side needs Preferences -> Connections -> USB Connection ->
# GoPro Connect, plus a data-capable USB-C cable.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.denis.goproWebcam;

  # Kernel 7.3's `make modules_install` writes depmod metadata (an empty
  # modules.builtin.bin among them) next to v4l2loopback.ko. NixOS merges
  # boot.extraModulePackages with the kernel's own modules tree and aborts on
  # the collision — same path, different content. Only the .ko is wanted; the
  # merged tree is depmod'd again on its own.
  v4l2loopback = config.boot.kernelPackages.v4l2loopback.overrideAttrs (old: {
    postInstall = (old.postInstall or "") + ''
      find $out/lib/modules -type f \
        -name 'modules.builtin*' -o -name 'modules.dep*' -o -name 'modules.alias*' \
        -o -name 'modules.softdep' -o -name 'modules.symbols*' -o -name 'modules.devname' \
        | xargs -r rm -f
    '';
  });
in
{
  options.denis.goproWebcam = {
    enable = lib.mkEnableOption "the GoPro USB webcam bridge (v4l2loopback + `gopro-webcam`)";

    videoNumber = lib.mkOption {
      type = lib.types.int;
      default = 42;
      description = "Which /dev/videoN the virtual GoPro camera gets.";
    };
  };

  config = lib.mkIf cfg.enable {
    # ── Virtual camera device ─────────────────────────────
    # Loaded at boot so /dev/video42 is always there; `exclusive_caps=1`
    # keeps the device out of capture-app lists until something writes to
    # it (a v4l2loopback without it shows up twice and confuses clients).
    boot.extraModulePackages = [ v4l2loopback ];
    boot.kernelModules = [ "v4l2loopback" ];
    boot.extraModprobeConfig = ''
      options v4l2loopback devices=1 video_nr=${toString cfg.videoNumber} card_label="GoPro" exclusive_caps=1
    '';

    # v4l2loopback nodes are root:video — membership is what lets ffmpeg
    # write them without sudo.
    users.users.denis.extraGroups = [ "video" ];

    environment.systemPackages = [
      (pkgs.callPackage ../pkgs/gopro-webcam { })
      pkgs.v4l-utils
      pkgs.usbutils
    ];

    # The camera streams back to whoever asked for the stream, arriving on
    # the USB ethernet interface (named enx<mac> by predictable naming). The
    # firewall here is the iptables backend, and `+` matches any interface
    # name with that prefix — so the rule holds whatever the camera's MAC is,
    # and never exposes the port on wifi or the wired LAN.
    networking.firewall.extraCommands = ''
      iptables -A nixos-fw -i enx+ -p udp --dport 8554 -j nixos-fw-accept
    '';
    networking.firewall.extraStopCommands = ''
      iptables -D nixos-fw -i enx+ -p udp --dport 8554 -j nixos-fw-accept 2>/dev/null || true
    '';
  };
}
