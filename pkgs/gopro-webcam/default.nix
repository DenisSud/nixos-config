# `gopro-webcam` — the GoPro USB webcam bridge installed by
# modules/gopro-webcam.nix (denis.goproWebcam.enable).
#
# The logic is gopro-webcam.sh; this expression only pins the tools it
# shells out to. v4l2loopback supplies the /dev/videoN device; ffmpeg turns
# the camera's MPEG-TS/UDP stream into frames on it.
{
  pkgs,
}:

pkgs.writeShellApplication {
  name = "gopro-webcam";

  runtimeInputs = with pkgs; [
    ffmpeg # udp://:8554 -> /dev/video42
    curl # /gp/gpWebcam/{START,STOP,SETTINGS}
    iproute2 # ip -4 -o addr: find the camera's enx* interface
    gawk # address/interface parsing
    gnugrep
    v4l-utils # v4l2-ctl --list-devices / --get-fmt-video
  ];

  text = builtins.readFile ./gopro-webcam.sh;
}
