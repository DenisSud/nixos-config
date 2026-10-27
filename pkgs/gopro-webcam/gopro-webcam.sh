# gopro-webcam — use a GoPro (HERO8 and later) as a webcam on Linux, no
# capture card, no Media Mod.
#
# In "GoPro Connect" USB mode the camera enumerates as a USB ethernet
# adapter: the kernel brings up a network interface for it, the camera
# answers HTTP on the .51 address of that subnet, and after a single HTTP
# request it blasts MPEG-TS/H.264 at UDP 8554 back to the host. Two steps,
# both done here:
#
#   1. GET http://<cam>/gp/gpWebcam/START?res=1080&port=8554
#   2. ffmpeg udp://:8554 -> /dev/video42 (the v4l2loopback device)
#
# Every app then sees a plain 1080p30 webcam named "GoPro". The camera's own
# UI shows a webcam icon while streaming; Ctrl-C stops the stream and tells
# the camera to drop out of webcam mode.
#
# The interface name is not something to rely on: the HERO9 reports a
# locally-administered MAC, so systemd's predictable naming falls back to the
# slot (enp10s0u5 on a desktop, enx<mac> for models that do report one).
# Discovery goes by USB vendor id instead — the interface is the one hanging
# off a 2672 (GoPro) USB device.
set -euo pipefail

RES=1080
FOV=linear
PORT=8554
OUT=/dev/video42
IFACE=
CAM_IP=
GOPRO_VENDOR=2672

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
    --iface IFACE               pin the camera's network interface
    --ip 172.2X.X.51            pin the camera address
  gopro-webcam status          camera, interface and virtual device state
  gopro-webcam stop            tell the camera to leave webcam mode

The camera must be on, plugged in with a data-capable USB-C cable, and set
to Preferences -> Connections -> USB Connection -> GoPro Connect. If no
interface appears, reset the camera side with Preferences -> Connections ->
Reset Connections (unplugging is not enough, USB keeps it powered).
EOF
}

# First idVendor found walking up from the netdev: for a USB ethernet gadget
# that is the camera itself (…/1-5:1.0 -> …/1-5/idVendor = 2672).
usb_vendor_of() {
  local dir
  dir=$(readlink -f "/sys/class/net/$1/device" 2>/dev/null) || return 1
  while [ -n "$dir" ] && [ "$dir" != / ]; do
    if [ -f "$dir/idVendor" ]; then
      cat "$dir/idVendor"
      return 0
    fi
    dir=$(dirname "$dir")
  done
  return 1
}

ipv4_of() {
  ip -4 -o addr show dev "$1" 2>/dev/null | awk '{print $4}' | cut -d/ -f1 | head -1
}

# DHCP from the camera takes a moment after the interface shows up.
wait_ipv4() {
  local iface=$1 tries=${2:-10} i=0 addr
  while [ "$i" -lt "$tries" ]; do
    addr=$(ipv4_of "$iface")
    if [ -n "$addr" ]; then
      printf '%s\n' "$addr"
      return 0
    fi
    sleep 1
    i=$((i + 1))
  done
  return 1
}

# The camera always sits at .51 of the subnet the host got an address in.
discover() {
  [ -n "$CAM_IP" ] && return 0

  local d iface addr v

  if [ -z "$IFACE" ]; then
    # Anyone handing us an interface is doing it on purpose.
    for d in /sys/class/net/*; do
      iface=$(basename "$d")
      [ "$iface" = lo ] && continue
      v=$(usb_vendor_of "$iface" 2>/dev/null) || continue
      [ "$v" = "$GOPRO_VENDOR" ] && { IFACE=$iface; break; }
    done
  fi

  if [ -z "$IFACE" ]; then
    # Fallback: a USB ethernet interface on the camera's 172.x subnet.
    for d in /sys/class/net/*; do
      iface=$(basename "$d")
      case $iface in enx* | usb*) : ;; *) continue ;; esac
      addr=$(ipv4_of "$iface")
      case ${addr:-} in 172.*) IFACE=$iface; break ;; esac
    done
  fi

  [ -n "$IFACE" ] || die "no GoPro USB network interface. Camera on, USB-C data cable, USB Connection = GoPro Connect (not MTP)."

  addr=$(wait_ipv4 "$IFACE" 10) \
    || die "interface $IFACE has no IPv4 address yet — NetworkManager still bringing it up? (ip -4 addr show dev $IFACE)"

  CAM_IP="${addr%.*}.51"
  say "camera at $CAM_IP via $IFACE"
}

start_stream() {
  local url="http://$CAM_IP/gp/gpWebcam/START?res=$RES&port=$PORT"
  curl -fsS --max-time 8 "$url" >/dev/null \
    || die "camera at $CAM_IP refused webcam mode ($url). Try Preferences -> Connections -> Reset Connections on the camera."

  local fov_id=4
  case $FOV in
    wide) fov_id=0 ;;
    linear) fov_id=4 ;;
    narrow) fov_id=2 ;;
    superview) fov_id=3 ;;
  esac
  curl -fsS --max-time 8 "http://$CAM_IP/gp/gpWebcam/SETTINGS?fov=$fov_id" >/dev/null \
    || say "warning: could not set FOV to $FOV"

  say "streaming ${RES}p ($FOV) from the camera to udp/$PORT, feeding $OUT"
}

stop_stream() {
  [ -n "$CAM_IP" ] || discover
  curl -fsS --max-time 5 "http://$CAM_IP/gp/gpWebcam/STOP" >/dev/null 2>&1 || true
}

run() {
  discover

  [ -e "$OUT" ] || die "$OUT is missing — is v4l2loopback loaded? (lsmod | grep v4l2loopback)"

  if ! v4l2-ctl -d "$OUT" --all >/dev/null 2>&1; then
    say "warning: $OUT not readable (the user should be in the 'video' group)"
  fi

  start_stream
  trap 'stop_stream; [ -n "${FFMPEG_PID:-}" ] && kill "$FFMPEG_PID" 2>/dev/null || true' INT TERM EXIT

  ffmpeg -hide_banner -nostdin \
    -fflags nobuffer -flags low_delay \
    -probesize 1000000 -analyzeduration 500000 \
    -i "udp://@0.0.0.0:$PORT?overrun_nonfatal=1&fifo_size=50000000" \
    -map 0:v:0 -vf format=yuv420p \
    -loglevel error -f v4l2 "$OUT" &
  FFMPEG_PID=$!
  wait "$FFMPEG_PID" || say "ffmpeg exited — the camera stopped sending, or the cable dropped"
}

status() {
  local d iface v addr found=

  printf '== camera interface ==\n'
  for d in /sys/class/net/*; do
    iface=$(basename "$d")
    [ "$iface" = lo ] && continue
    v=$(usb_vendor_of "$iface" 2>/dev/null) || continue
    [ "$v" = "$GOPRO_VENDOR" ] || continue
    addr=$(ipv4_of "$iface")
    printf '  %s  %s  -> camera %s\n' "$iface" "${addr:-no ipv4}" "${addr:+${addr%.*}.51}"
    found=1
  done
  [ -n "$found" ] || printf '  none — camera not in GoPro Connect mode, or not plugged in\n'

  printf '== virtual camera ==\n'
  if [ -e "$OUT" ]; then
    printf '  %s (%s)\n' "$OUT" "$(cat "/sys/class/video4linux/$(basename "$OUT")/name" 2>/dev/null)"
    v4l2-ctl -d "$OUT" --get-fmt-video 2>/dev/null | sed -n '2,3p' | sed 's/^\t*/    /' || true
  else
    printf '  %s missing — v4l2loopback not loaded?\n' "$OUT"
  fi

  printf '== firewall ==\n'
  printf '  udp/%s from 172.16.0.0/12 must be accepted (the camera subnet)\n' "$PORT"
}

cmd=start
if [ $# -gt 0 ]; then
  case $1 in
    -h | --help | help) usage; exit 0 ;;
    start | status | stop)
      cmd=$1
      shift
      ;;
  esac
fi

while [ $# -gt 0 ]; do
  case $1 in
    --res) RES=$2; shift ;;
    --fov) FOV=$2; shift ;;
    --out) OUT=$2; shift ;;
    --iface) IFACE=$2; shift ;;
    --ip) CAM_IP=$2; shift ;;
    --port) PORT=$2; shift ;;
    -h | --help) usage; exit 0 ;;
    *) die "unknown option: $1 (try --help)" ;;
  esac
  shift
done

case $cmd in
  start) run ;;
  status) status ;;
  stop)
    stop_stream
    say "camera told to leave webcam mode"
    ;;
esac
