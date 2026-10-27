# `vpn-passthrough` — policy routing that keeps declared destinations off a
# TUN VPN. Installed by modules/vpn-passthrough.nix
# (denis.vpnPassthrough.enable).
#
# The logic is vpn-passthrough.sh; this expression only pins the tools it
# shells out to and bakes in the configuration, so `vpn-passthrough status`
# works from a shell without the unit's environment.
{
  pkgs,
  lib,
  table,
  rulePriority,
  localNetworks,
  destinations,
}:

pkgs.writeShellApplication {
  name = "vpn-passthrough";

  runtimeInputs = with pkgs; [
    iproute2 # ip rule / ip route / ip -j
    jq # parsing ip's JSON
  ];

  runtimeEnv = {
    VPN_PASSTHROUGH_TABLE = toString table;
    VPN_PASSTHROUGH_RULE_PRIORITY = toString rulePriority;
    VPN_PASSTHROUGH_LOCAL_NETWORKS = if localNetworks then "1" else "0";
    VPN_PASSTHROUGH_DESTINATIONS = lib.concatStringsSep " " destinations;
  };

  text = builtins.readFile ./vpn-passthrough.sh;
}
