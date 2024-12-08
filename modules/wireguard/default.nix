{ config, lib, pkgs, ... }:
with lib;
{
  imports = [
    ./interfaces.nix
  ];
}
