# anime-matrix — put images, gifs, video and text on the ASUS ROG AniMe
# Matrix lid display through asusd. asusd keeps running, so fan curves,
# profiles and supergfxd keep working: frames are pushed at the daemon over
# D-Bus instead of opening the USB device directly (what the third-party
# AniMe apps do, and why they ask you to stop asusd).
#
# The GA401 (G14 2020/21) panel is a 33 x 55 diagonal lattice with 16
# brightness levels. asusctl resamples the source itself: it aspect-fits the
# image into the panel rect, so the source only needs the right *aspect*
# (78x48 by default below). Pre-scaling with ffmpeg still matters — feeding
# it a 1080p gif gives mushier LEDs than a 78x48 one.
#
# Nothing declarative here on purpose: the prepared frame/gif lives in
# ~/.cache/anime-matrix, the current choice in ~/.local/state/anime-matrix/
# current, and `anime-matrix.service` replays that choice at login. Change
# what is on the lid without rebuilding.
set -euo pipefail

# Filled in by default.nix.
: "${ASUS_GIFS:?}"
: "${FONT:?}"

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/anime-matrix"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/anime-matrix"
SPEC_FILE="$STATE_DIR/current"
UNIT=anime-matrix.service

# 78x48 is the aspect of the panel rect (26.8 x 16.5 in asusctl's units), so
# images made at this size fill the lattice instead of being letterboxed.
# 74x36 is the aspect ASUS ships its own gifs in.
SIZE=78x48
FPS=15
BRIGHT=1.0

die() { printf 'anime-matrix: %s\n' "$*" >&2; exit 1; }
say() { printf 'anime-matrix: %s\n' "$*" >&2; }

usage() {
  cat <<'EOF'
anime-matrix — AniMe Matrix lid display control (via asusd, no daemon juggling)

usage:
  anime-matrix show FILE        image, gif or video onto the lid, remembered
    --size WxH                  render size            (default 78x48, fills panel)
    --fps N                     gif/video frame rate   (default 15)
    --bright 0.0-1.0            per-frame brightness   (default 1.0)
  anime-matrix text STRING      text on the lid, auto-sized
    --scroll                    scroll it right to left
  anime-matrix preset NAME      play a gif bundled with asusctl
  anime-matrix presets          list those gifs
  anime-matrix stop             stop and clear the lid, forget the choice
  anime-matrix status           what is playing + panel switches
  anime-matrix brightness off|low|med|high
                                base brightness of the panel
  anime-matrix battery on|off   blank the panel while on battery
EOF
}

# ── state ────────────────────────────────────────────────
write_spec() { # out kind bright src
  mkdir -p "$STATE_DIR"
  printf 'out=%s\nkind=%s\nbright=%s\nsrc=%s\n' "$1" "$2" "$3" "$4" >"$SPEC_FILE"
}

read_spec() { # sets SPEC_OUT/SPEC_KIND/SPEC_BRIGHT/SPEC_SRC
  [ -f "$SPEC_FILE" ] || return 1
  SPEC_OUT="" SPEC_KIND="" SPEC_BRIGHT=1.0 SPEC_SRC=""
  while IFS='=' read -r key value; do
    case "$key" in
      out) SPEC_OUT=$value ;;
      kind) SPEC_KIND=$value ;;
      bright) SPEC_BRIGHT=$value ;;
      src) SPEC_SRC=$value ;;
    esac
  done <"$SPEC_FILE"
  [ -n "$SPEC_OUT" ]
}

# ── conversion ───────────────────────────────────────────
parse_size() {
  WIDTH=${SIZE%x*}
  HEIGHT=${SIZE#*x}
  case "$WIDTH$HEIGHT" in
    *[!0-9]* | "") die "bad --size: $SIZE (want WxH, e.g. 78x48)" ;;
  esac
}

# Prepares $1 into $OUT of kind $OUT_KIND (image|gif).
prepare() {
  local src=$1 frames fit
  parse_size
  fit="scale=$WIDTH:$HEIGHT:force_original_aspect_ratio=decrease:flags=lanczos"
  fit="$fit,pad=$WIDTH:$HEIGHT:-1:-1:color=black,format=gray"

  mkdir -p "$CACHE_DIR"

  frames=$(ffprobe -v error -select_streams v:0 -count_frames \
    -show_entries stream=nb_read_frames -of default=nw=1:nk=1 "$src" 2>/dev/null |
    head -1 || true)
  case "$frames" in
    "" | *[!0-9]*) frames=0 ;;
  esac

  if [ "$frames" -le 1 ]; then
    OUT="$CACHE_DIR/frame.png"
    OUT_KIND=image
    ffmpeg -nostdin -y -v error -i "$src" -vf "$fit" -frames:v 1 \
      -pix_fmt gray "$OUT"
  else
    OUT="$CACHE_DIR/anim.gif"
    OUT_KIND=gif
    # 16 colours matches the panel's 4 bits of greyscale. asusctl averages
    # source pixels onto each LED, so ordered dithering here buys a couple of
    # extra apparent levels.
    ffmpeg -nostdin -y -v error -i "$src" -vf \
      "fps=$FPS,$fit,split[a][b];[a]palettegen=max_colors=16:stats_mode=diff:reserve_transparent=0[p];[b][p]paletteuse=dither=bayer:bayer_scale=3:diff_mode=rectangle" \
      -loop 0 "$OUT"
  fi
}

start_unit() { # src
  write_spec "$OUT" "$OUT_KIND" "$BRIGHT" "$1"
  if ! systemctl --user restart "$UNIT" 2>/dev/null; then
    systemctl --user start "$UNIT" ||
      die "could not start $UNIT (is the systemd user manager up?)"
  fi
}

# ── commands ─────────────────────────────────────────────
cmd_show() {
  local src=""
  while [ $# -gt 0 ]; do
    case "$1" in
      --size) SIZE=${2:?--size needs WxH}; shift 2 ;;
      --fps) FPS=${2:?--fps needs a number}; shift 2 ;;
      --bright) BRIGHT=${2:?--bright needs 0.0-1.0}; shift 2 ;;
      -h | --help) usage; exit 0 ;;
      --*) die "unknown option: $1" ;;
      *)
        [ -z "$src" ] || die "one file at a time"
        src=$1
        shift
        ;;
    esac
  done
  [ -n "$src" ] || die "usage: anime-matrix show FILE"
  [ -f "$src" ] || die "no such file: $src"

  prepare "$src"
  start_unit "$src"
  say "playing $OUT_KIND from $src"
}

cmd_text() {
  local str="" scroll=0 textfile draw fontsize speed
  while [ $# -gt 0 ]; do
    case "$1" in
      --scroll) scroll=1; shift ;;
      --size) SIZE=${2:?--size needs WxH}; shift 2 ;;
      --fps) FPS=${2:?--fps needs a number}; shift 2 ;;
      --bright) BRIGHT=${2:?--bright needs 0.0-1.0}; shift 2 ;;
      -h | --help) usage; exit 0 ;;
      --*) die "unknown option: $1" ;;
      *)
        [ -z "$str" ] || die "one string at a time"
        str=$1
        shift
        ;;
    esac
  done
  [ -n "$str" ] || die 'usage: anime-matrix text "STRING"'
  parse_size

  mkdir -p "$CACHE_DIR"
  # drawtext parses its value as a filtergraph fragment; textfile= keeps the
  # string out of it, so quotes, colons and commas need no escaping.
  textfile="$CACHE_DIR/text.txt"
  printf '%s' "$str" >"$textfile"

  # 0.62em is roughly the average advance of DejaVu Sans Bold, so the string
  # fits the panel width without a measure pass.
  fontsize=$((WIDTH * 100 / (62 * ${#str})))
  if [ "$fontsize" -gt $((HEIGHT * 85 / 100)) ]; then
    fontsize=$((HEIGHT * 85 / 100))
  fi
  if [ "$fontsize" -lt 6 ]; then
    fontsize=6
  fi

  draw="drawtext=fontfile=$FONT:textfile=$textfile:fontcolor=white"
  draw="$draw:fontsize=$fontsize"

  if [ "$scroll" = 1 ]; then
    OUT="$CACHE_DIR/anim.gif"
    OUT_KIND=gif
    speed=$((WIDTH / 2))
    if [ "$speed" -lt 10 ]; then
      speed=10
    fi
    # 6s of travel at a fixed speed, then the gif loops. `tw` is the text
    # width drawtext reports, so the scroll is seamless for any string.
    ffmpeg -nostdin -y -v error \
      -f lavfi -i "color=black:s=${WIDTH}x${HEIGHT}:d=6" \
      -vf "fps=$FPS,$draw:x=w-mod(t*$speed\\,w+tw):y=(h-th)/2,format=gray" \
      -loop 0 "$OUT"
  else
    OUT="$CACHE_DIR/frame.png"
    OUT_KIND=image
    ffmpeg -nostdin -y -v error \
      -f lavfi -i "color=black:s=${WIDTH}x${HEIGHT}" \
      -vf "$draw:x=(w-tw)/2:y=(h-th)/2,format=gray" \
      -frames:v 1 -pix_fmt gray "$OUT"
  fi

  start_unit "text: $str"
  say "showing \"$str\""
}

cmd_presets() {
  [ -d "$ASUS_GIFS" ] || die "no bundled gifs at $ASUS_GIFS"
  find "$ASUS_GIFS" -name '*.gif' -printf '%P\n' | sed 's/\.gif$//' | sort
}

cmd_preset() {
  local name=${1:?usage: anime-matrix preset NAME} gif
  local -a hits=()
  while IFS= read -r gif; do
    if [[ ${gif,,} == *"${name,,}"* ]]; then
      hits+=("$gif")
    fi
  done < <(find "$ASUS_GIFS" -name '*.gif' | sort)

  if [ "${#hits[@]}" -eq 0 ]; then
    die "no bundled gif matches \"$name\" (try: anime-matrix presets)"
  fi
  if [ "${#hits[@]}" -gt 1 ]; then
    printf 'multiple matches, be more specific:\n' >&2
    printf '  %s\n' "${hits[@]##*/}" >&2
    exit 1
  fi
  cmd_show "${hits[0]}"
}

cmd_stop() {
  systemctl --user stop "$UNIT" 2>/dev/null || true
  rm -f "$SPEC_FILE"
  asusctl anime --clear >/dev/null
  asusctl anime --enable-powersave-anim true >/dev/null
  say "stopped, panel cleared"
}

device_prop() { # property
  busctl --system get-property xyz.ljones.Asusd /xyz/ljones/aura/anime \
    xyz.ljones.Anime "$1" 2>/dev/null | awk '{print $2}'
}

panel_switch() { # property -> human readable
  case "$(device_prop "$1")" in
    true) echo "panel off" ;;
    false) echo "panel stays on" ;;
    *) echo "?" ;;
  esac
}

cmd_status() {
  local state
  state=$(systemctl --user is-active "$UNIT" 2>/dev/null || true)
  printf 'service:    %s\n' "${state:-unknown}"
  if read_spec; then
    printf 'showing:    %s (%s, bright %s)\n' "$SPEC_SRC" "$SPEC_KIND" "$SPEC_BRIGHT"
    printf 'rendered:   %s\n' "$SPEC_OUT"
  else
    printf 'showing:    nothing custom (builtin animations)\n'
  fi
  printf 'display:    %s\n' "$(device_prop EnableDisplay || echo '?')"
  printf 'brightness: %s (0=off 1=low 2=med 3=high)\n' \
    "$(device_prop Brightness || echo '?')"
  printf 'on battery: %s\n' "$(panel_switch OffWhenUnplugged)"
  printf 'lid closed: %s\n' "$(panel_switch OffWhenLidClosed)"
  printf 'suspended:  %s\n' "$(panel_switch OffWhenSuspended)"
}

cmd_brightness() {
  local level=${1:?usage: anime-matrix brightness off|low|med|high}
  case "$level" in
    off | low | med | high) ;;
    *) die "brightness wants off|low|med|high" ;;
  esac
  asusctl anime --brightness "$level" >/dev/null
  say "panel brightness: $level"
}

cmd_battery() {
  local mode=${1:?usage: anime-matrix battery on|off}
  case "$mode" in
    on)
      asusctl anime --off-when-unplugged true >/dev/null
      say "panel goes dark on battery"
      ;;
    off)
      asusctl anime --off-when-unplugged false >/dev/null
      say "panel stays on battery"
      ;;
    *) die "battery wants on|off" ;;
  esac
}

# Replays the saved choice; this is what anime-matrix.service runs at login.
# A clean exit means "nothing saved", so the unit is not restarted.
cmd_run() {
  read_spec || exit 0
  if ! systemctl is-active --quiet asusd; then
    say "asusd is not running, not touching the lid"
    exit 0
  fi
  # asusd's own loop would stomp the frames we stream at it.
  asusctl anime --enable-powersave-anim false >/dev/null || true
  if [ "$SPEC_KIND" = image ]; then
    exec asusctl anime image --path "$SPEC_OUT" --bright "$SPEC_BRIGHT"
  fi
  exec asusctl anime gif --path "$SPEC_OUT" --bright "$SPEC_BRIGHT" --loops 0
}

case "${1:-}" in
  show) shift; cmd_show "$@" ;;
  text) shift; cmd_text "$@" ;;
  preset) shift; cmd_preset "$@" ;;
  presets) shift; cmd_presets "$@" ;;
  stop) shift; cmd_stop "$@" ;;
  status) shift; cmd_status "$@" ;;
  brightness) shift; cmd_brightness "$@" ;;
  battery) shift; cmd_battery "$@" ;;
  _run) shift; cmd_run "$@" ;;
  -h | --help | help | "") usage ;;
  *) die "unknown command: $1 (try: anime-matrix --help)" ;;
esac
