# gopro-webcam — use a GoPro (HERO8 and later) as a webcam on Linux, no
# capture card, no Media Mod.
#
# In "GoPro Connect" USB mode the camera enumerates as a USB ethernet
# adapter: the kernel brings up an `enx<mac>` interface of its own, the
# camera answers HTTP on the .51 address of that subnet, and after a single
# HTTP request it blasts MPEG-TS/H.264 at UDP 8554 back to the host. Two
# steps, both done here:
#
#   1. GET http://<cam>/gp/gpWebcam/START?res=1080&port=8554
#   2. ffmpeg udp://:8554 -> /dev/video42 (the v4l2loopback device)
#
# Every app then sees a plain 1080p30 webcam named "GoPro". The camera's own
# UI shows a webcam icon while streaming; Ctrl-C stops the stream and tells
# the camera to drop out of webcam mode.
set -euo pipefail

RES=1080
FOV=linear
PORT=8554
OUT=/dev/video42
IFACE=
CAM_IP=

die() { printf 'gopro-webcam: %s\n' "$*" >&2; exit 1; }
say() { printf 'gopro-webcam: %s\n' "$*" >&2; }

usage() {
  cat <<'EOF'
gopro-webcam — GoPro as a Linux webcam over USB (v4l2loopback)

usage:
  gopro-webcam [start]          start streaming into the virtual camera
    --res 1080|720|480          stream resolution          (default 1080)
    --fov wide|linear|narrow|superview                       (default linear)
    --out /dev/videoN           v4l2loopback device         (default /dev/video42)
    --iface enxXXXX             pin the camera's USB interface
    --ip 172.2X.X.51            pin the camera address
  gopro-webcam status          camera, interface and virtual device state
  gopro-webcam stop            tell the camera to leave webcam mode

The camera must be on, plugged in with a data-capable USB-C cable, and set
to Preferences -> Connections -> USB Connection -> GoPro Connect. If the
interface never appears, reset the camera side with Preferences ->
Connections -> Reset Connections (unplugging is not enough, USB keeps it
powered).
EOF
}

# The camera always sits at .51 of the subnet the host got an address in, so
# discovery is "which USB-ethernet interface has an IPv4". Prefer a 172.x
# address, which is what every webcam-capable model hands out.
discover() {
  [ -n "$CAM_IP" ] && return 0

  local iface cidr ip first=
  local -a gopros=()

  while read -r iface cidr; do
    [ -n "$iface" ] || continue
    ip=${cidr%/*}
    gopros+=("$iface $ip")
    [ -z "$first" ] && first="$iface $ip"
    case $ip in 172.*) IFACE=$iface; CAM_IP="${ip%.*}.51"; return 0 ;; esac
  done < <(ip -4 -o addr show | awk '$2 ~ /^enx[0-9a-f]/ { print $2, $4 }')

  [ -n "$IFACE" ] && return 0

  if [ -n "$first" ]; then
    IFACE=${first%% *}
    CAM_IP="${first##* }.51"
    say "no 172.x USB interface, guessing $IFACE -> $CAM_IP"
    return 0
  fi

  die "no USB ethernet interface found. Plug the camera in, turn it on, and check that USB Connection is set to GoPro Connect (not MTP)."
}

start_stream() {
  local url="http://$CAM_IP/gp/gpWebcam/START?res=$RES&port=$PORT"
  curl -fsS --max-time 8 "$url" >/dev/null \
    || die "camera at $CAM_IP did not accept webcam mode ($url). Try: Preferences -> Connections -> Reset Connections on the camera."

  local fov_id=4
  case $FOV in
    wide) fov_id=0 ;;
    linear) fov_id=4 ;;
    narrow) fov_id=2 ;;
    superview) fov_id=3 ;;
  esac
  curl -fsS --max-time 8 "http://$CAM_IP/gp/gpWebcam/SETTINGS?fov=$fov_id" >/dev/null \
    || say "warning: could not set FOV to $FOV"

  say "camera streaming ${RES}p ($FOV) to udp/$PORT, feeding $OUT"
}

stop_stream() {
  [ -n "$CAM_IP" ] || discover
  curl -fsS --max-time 5 "http://$CAM_IP/gp/gpWebcam/STOP" >/dev/null 2>&1 || true
}

run() {
  discover

  [ -e "$OUT" ] || die "$OUT is missing — is v4l2loopback loaded? (lsmod | grep v4l2loopback)"

  if ! v4l2-ctl -d "$OUT" --all >/dev/null 2>&1; then
    say "warning: $OUT is not readable (permissions? the denis user should be in the 'video' group)"
  fi

  start_stream
  trap 'say "stopping"; stop_stream; [ -n "${FFMPEG_PID:-}" ] && kill "$FFMPEG_PID" 2>/dev/null || true' INT TERM EXIT

  ffmpeg -hide_banner -nostdin \
    -fflags nobuffer -flags low_delay \
    -i "udp://@0.0.0.0:$PORT?overrun_nonfatal=1&fifo_size=50000000" \
    -vf format=yuv420p \
    -f v4l2 "$OUT" &
  FFMPEG_PID=$!
  wait "$FFMPEG_PID" || say "ffmpeg exited — the camera stopped sending or the cable dropped"
}

status() {
  printf '== usb ethernet interfaces ==\n'
  ip -4 -o addr show | awk '$2 ~ /^enx[0-9a-f]/ { printf "  %s  %s\n", $2, $4 }'
  printf '== virtual camera ==\n'
  v4l2-ctl --list-devices 2>/dev/null | grep -B1 -A2 GoPro || printf '  GoPro device not found (v4l2loopback not loaded?)\n'
  if v4l2-ctl -d "$OUT" --all >/dev/null 2>&1; then
    v4l2-ctl -d "$OUT" --get-fmt-video 2>/dev/null | sed 's/^/  /'
  fi
  printf '== firewall ==\n'
  printf '  udp/%s inbound must reach the enx* interface\n' "$PORT"
}

cmd=start
[ $# -gt 0 ] && case $1 in -h|--help|help) usage; exit 0 ;; start|status|stop) cmd=$1; shift ;; esac

while [ $# -gt 0 ]; do
  case $1 in
    --res) RES=$2; shift ;;
    --fov) FOV=$2; shift ;;
    --out) OUT=$2; shift ;;
    --iface) IFACE=$2; shift ;;
    --ip) CAM_IP=$2; shift ;;
    --port) PORT=$2; shift ;;
    -h|--help) usage; exit 0 ;;
    *) die "unknown option: $1 (try --help)" ;;
  esac
  shift
done

case $cmd in
  start) run ;;
  status) status ;;
  stop) stop_stream; say "camera told to leave webcam mode" ;;
esac
