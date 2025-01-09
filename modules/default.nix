{ config, lib, pkgs, ... }:
{
  imports = [
    ./base
    ./desktop
    ./users
    ./hardware
  ];
}
