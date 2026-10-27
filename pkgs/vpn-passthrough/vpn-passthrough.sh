# vpn-passthrough — keep declared destinations on the physical uplink while a
# TUN VPN owns the default route.
#
# Why this is not just "a route in main": Happ's TUN is sing-box with
# auto_route, and auto_route installs a policy chain in front of the main
# table — its own table (2022) plus rules at priorities 9000 and up, the last
# of which sends *every* destination into that table. A route sitting in
# `main` is then never consulted, so the exclusion has to be a rule of our own
# at a priority above 9000's:
#
#        1000:  from all to 201.51.3.119 lookup 1090     <- this script
#        9002:  from all lookup 2022                     <- sing-box
#        9003:  from all iif lo ... lookup 2022
#       32766:  from all lookup main
#
# Table 1090 mirrors `main` minus any tunnel device, so it answers the way the
# host would answer with the tunnel switched off: the physical default route
# for the internet, the on-link routes for the LAN and the podman bridges. A
# rule whose table has no matching route falls through to the next rule, so a
# table that is empty or one DHCP lease behind degrades to the tunnel instead
# of black-holing traffic.
#
# The rules are static. They do not depend on the tunnel being up, so the
# tunnel coming and going never re-installs anything; only the table follows
# the physical uplink, which is what `apply` reconciles.
#
#   vpn-passthrough apply     reconcile table + rules (root)
#   vpn-passthrough status    table, rules, and where each destination leaves
#   vpn-passthrough guard     exit 1 when a destination would enter the tunnel
set -euo pipefail

TABLE=${VPN_PASSTHROUGH_TABLE:?VPN_PASSTHROUGH_TABLE is not set}
PRIORITY=${VPN_PASSTHROUGH_RULE_PRIORITY:?VPN_PASSTHROUGH_RULE_PRIORITY is not set}
LOCAL_NETWORKS=${VPN_PASSTHROUGH_LOCAL_NETWORKS:-0}
read -r -a DESTINATIONS <<<"${VPN_PASSTHROUGH_DESTINATIONS:-}"

# Anything routable. Only used to ask the kernel which device carries the
# default route; nothing is sent anywhere.
PROBE4=1.1.1.1
PROBE6=2606:4700:4700::1111

CHANGED=0

say() { printf 'vpn-passthrough: %s\n' "$*" >&2; }

usage() {
  cat <<'EOF'
vpn-passthrough — keep declared destinations off a TUN VPN

usage:
  vpn-passthrough apply     install the policy table and the per-destination
                            rules (root)
  vpn-passthrough status    show the table, the rules and the exit device of
                            every destination
  vpn-passthrough guard     exit 1 if a declared destination would leave
                            through the tunnel while the tunnel owns the
                            default route
  vpn-passthrough help      this text

Configured through the environment, all baked in by
modules/vpn-passthrough.nix so the commands above need no arguments:
  VPN_PASSTHROUGH_TABLE              policy table number
  VPN_PASSTHROUGH_RULE_PRIORITY      ip rule preference
  VPN_PASSTHROUGH_DESTINATIONS       space-separated IPs/CIDRs
  VPN_PASSTHROUGH_LOCAL_NETWORKS     1 = also keep every directly connected
                                     prefix off the tunnel
EOF
}

is_tunnel() {
  local dev=$1
  [ -n "$dev" ] || return 1
  # tun/tap carry tun_flags; everything else here is a name convention.
  if [ -e "/sys/class/net/$dev/tun_flags" ]; then
    return 0
  fi
  case $dev in
    tun | tun[0-9]* | tap | tap[0-9]* | wg[0-9]* | utun[0-9]* | happ-* | tailscale[0-9]* | nordlynx* | proton[0-9]*) return 0 ;;
  esac
  return 1
}

# Enumerated from `ip link` rather than /sys/class/net so that the answer is
# the interfaces of this network namespace, whatever /sys is mounted from.
tunnel_devs_json() {
  local dev out=""
  while IFS= read -r dev; do
    if is_tunnel "$dev"; then
      out+="${out:+,}\"$dev\""
    fi
  done < <(ip -j link show | jq -r '.[].ifname')
  printf '[%s]' "$out"
}

# `ip rule show` prints a host prefix without its /32 (or /128), so compare in
# that same canonical form: the string is also what `ip rule del` takes.
normalize_prefix() {
  case $1 in
    */32) printf '%s' "${1%/32}" ;;
    */128) printf '%s' "${1%/128}" ;;
    *) printf '%s' "$1" ;;
  esac
}

dest_family() {
  case $1 in
    *:*) printf '6' ;;
    *) printf '4' ;;
  esac
}

# One route, rendered as an `ip route` argument list. Built from the JSON
# fields rather than from the text output so that `expires`, `pref`,
# `linkdown` and the other tokens that cannot be re-added never make it in.
# shellcheck disable=SC2016 # $skip is jq's bind, not the shell's
JQ_ROUTE_SPEC='
  .[]
  | select(.dev != null)
  | select(.dev as $d | ($skip | index($d)) == null)
  | select($strict != "1" or (((.flags // []) | index("linkdown")) == null))
  | select($strict != "1" or (((.flags // []) | index("dead")) == null))
  | select($local != "1" or ((.dst // "") | test("^(fe[89ab][0-9a-f]:|ff[0-9a-f][0-9a-f]:|169\\.254\\.|::1/128$)") | not))
  | select(.nexthops == null and .multipath == null)
  | [
      (.dst // "default"),
      (if .gateway then "via \(.gateway)" else empty end),
      "dev \(.dev)",
      (if .protocol then "proto \(.protocol)" else empty end),
      (if .scope then "scope \(.scope)" else empty end),
      (if .prefsrc then "src \(.prefsrc)" else empty end),
      (if .metric != null then "metric \(.metric)" else empty end)
    ]
  | join(" ")
'

want_routes() {
  local family=$1 skip
  skip=$(tunnel_devs_json)
  ip -"$family" -j route show table main 2>/dev/null |
    jq -r --argjson skip "$skip" --arg strict 1 --arg local 1 "$JQ_ROUTE_SPEC" || true
}

have_routes() {
  local family=$1
  # No flag filtering here: a route this script installed is still the route it
  # wanted, even while the kernel reports it linkdown.
  ip -"$family" -j route show table "$TABLE" 2>/dev/null |
    jq -r --argjson skip '[]' --arg strict 0 --arg local 0 "$JQ_ROUTE_SPEC" || true
}

# Directly connected prefixes (no gateway): the LAN, the podman bridges,
# link-local. Read from the route table rather than from the interface
# addresses so the prefix is already masked.
on_link_prefixes() {
  local family=$1 skip
  skip=$(tunnel_devs_json)
  ip -"$family" -j route show table main 2>/dev/null |
    jq -r --argjson skip "$skip" '
      .[]
      | select(.dev != null and .dst != "default")
      | select(((.flags // []) | index("linkdown")) == null)
      | select(.dev as $d | ($skip | index($d)) == null)
      | select(.gateway == null and .nexthops == null and .multipath == null)
      | select((.dst | test("^(fe[89ab][0-9a-f]:|ff[0-9a-f][0-9a-f]:|169\\.254\\.|::1/128$)")) | not)
      | .dst
    '
}

want_rules() {
  local family=$1 dest
  {
    for dest in "${DESTINATIONS[@]}"; do
      [ -n "$dest" ] || continue
      [ "$(dest_family "$dest")" = "$family" ] || continue
      normalize_prefix "$dest"
      printf '\n'
    done
    if [ "$LOCAL_NETWORKS" = 1 ]; then
      on_link_prefixes "$family"
    fi
  } | sort -u
}

current_rules() {
  local family=$1
  ip -"$family" -j rule show 2>/dev/null |
    jq -r --argjson p "$PRIORITY" '.[] | select(.priority == $p) | "\(.dst // "all")\(if .dstlen then "/\(.dstlen)" else "" end)|\(.table)"'
}

sync_table() {
  local family=$1 spec
  local -A want=() have=()
  local -a argv=()

  while IFS= read -r spec; do want["$spec"]=1; done < <(want_routes "$family")
  while IFS= read -r spec; do have["$spec"]=1; done < <(have_routes "$family")

  # An empty mirror is useless and would only make the rule above send
  # passthrough traffic into the tunnel table; more importantly it is what a
  # failed `ip route show` looks like, and that must not empty the table.
  if [ "${#want[@]}" -eq 0 ]; then
    if [ "${#have[@]}" -ne 0 ]; then
      say "warning: IPv$family main table has no routes, leaving table $TABLE alone"
    fi
    return
  fi

  for spec in "${!want[@]}"; do
    [ -n "$spec" ] || continue
    [ -z "${have[$spec]:-}" ] || continue
    read -r -a argv <<<"$spec"
    ip -"$family" route replace "${argv[@]}" table "$TABLE"
    CHANGED=1
  done

  for spec in "${!have[@]}"; do
    [ -n "$spec" ] || continue
    [ -z "${want[$spec]:-}" ] || continue
    read -r -a argv <<<"$spec"
    ip -"$family" route del "${argv[@]}" table "$TABLE" 2>/dev/null || true
    CHANGED=1
  done
}

# Rules are added before the stale ones are dropped, so a destination never
# sits without its rule for the length of a reconcile.
sync_rules() {
  local family=$1 dest row dst tbl
  local -A want=() have=()
  local -a rows=()

  mapfile -t rows < <(current_rules "$family")
  for row in "${rows[@]}"; do
    [ -n "$row" ] || continue
    have["$row"]=1
  done

  while IFS= read -r dest; do
    [ -n "$dest" ] || continue
    want["$dest"]=1
    if [ -z "${have["$dest|$TABLE"]:-}" ]; then
      ip -"$family" rule add to "$dest" table "$TABLE" pref "$PRIORITY"
      CHANGED=1
    fi
  done < <(want_rules "$family")

  for row in "${rows[@]}"; do
    [ -n "$row" ] || continue
    dst=${row%%|*}
    tbl=${row#*|}
    if [ -z "${want[$dst]:-}" ]; then
      ip -"$family" rule del to "$dst" table "$tbl" pref "$PRIORITY" 2>/dev/null || true
      CHANGED=1
    fi
  done
}

default_dev() {
  local family=$1 probe=$PROBE4
  [ "$family" = 6 ] && probe=$PROBE6
  ip -"$family" -j route get "$probe" 2>/dev/null | jq -r '.[0].dev // ""' 2>/dev/null || true
}

# Where a destination actually leaves the host, following the policy rules —
# this is the same question `ip route get <dest>` answers for a human.
exit_dev() {
  local family=$1 host=${2%/*}
  ip -"$family" -j route get "$host" 2>/dev/null | jq -r '.[0].dev // "unreachable"' 2>/dev/null ||
    printf 'unreachable\n'
}

describe_tunnel() {
  local family=$1 dev
  dev=$(default_dev "$family")
  if is_tunnel "$dev"; then
    printf '%s (a tunnel)' "$dev"
  elif [ -n "$dev" ]; then
    printf '%s (no tunnel)' "$dev"
  else
    printf 'none'
  fi
}

indent() {
  local line
  while IFS= read -r line; do
    printf '  %s\n' "$line"
  done
}

print_summary() {
  local -a dests=()
  mapfile -t dests < <(want_rules 4; want_rules 6)
  printf 'vpn-passthrough: table %s mirrors the uplink; %s destination(s) stay off a tunnel at rule pref %s: %s\n' \
    "$TABLE" "${#dests[@]}" "$PRIORITY" "$(IFS=', '; printf '%s' "${dests[*]:-}")"
}

cmd_apply() {
  local family
  for family in 4 6; do
    sync_table "$family"
    sync_rules "$family"
  done
  if [ "$CHANGED" = 1 ] || [ "${VPN_PASSTHROUGH_VERBOSE:-0}" = 1 ]; then
    print_summary
  fi
}

cmd_status() {
  local family dest dev mark

  printf 'table %s:\n' "$TABLE"
  for family in 4 6; do
    ip -"$family" route show table "$TABLE" 2>/dev/null || true
  done | indent

  printf 'rules at priority %s:\n' "$PRIORITY"
  for family in 4 6; do
    current_rules "$family" | tr '|' ' '
  done | indent

  printf 'default route: v4 %s, v6 %s\n' "$(describe_tunnel 4)" "$(describe_tunnel 6)"

  printf 'destinations:\n'
  for family in 4 6; do
    while IFS= read -r dest; do
      [ -n "$dest" ] || continue
      dev=$(exit_dev "$family" "$dest")
      if is_tunnel "$dev"; then
        mark='via the tunnel'
      else
        mark='ok'
      fi
      printf '  %-24s -> %-12s %s\n' "$dest" "$dev" "$mark"
    done < <(want_rules "$family")
  done
}

cmd_guard() {
  local family dest dev tunnel failed=0
  for family in 4 6; do
    tunnel=$(default_dev "$family")
    is_tunnel "$tunnel" || continue
    while IFS= read -r dest; do
      [ -n "$dest" ] || continue
      dev=$(exit_dev "$family" "$dest")
      if is_tunnel "$dev" || [ "$dev" = unreachable ]; then
        say "FAIL: the default route is on $tunnel and $dest leaves through ${dev}, not the physical uplink"
        failed=1
      fi
    done < <(want_rules "$family")
  done
  if [ "$failed" = 1 ]; then
    say "a declared passthrough destination is inside the tunnel, so whatever needs the physical uplink stalls (the mason/tanya vpn sidecars, the LAN). Run \`vpn-passthrough status\`; \`systemctl restart vpn-passthrough\` re-applies the table."
    exit 1
  fi
  say "ok: no declared destination is routed into a tunnel"
}

case ${1:-} in
  apply) cmd_apply ;;
  status) cmd_status ;;
  guard) cmd_guard ;;
  '' | -h | --help | help) usage ;;
  *) usage >&2; exit 2 ;;
esac
