{ config, lib, pkgs, ... }:

{
  # Enable CUPS for printing documents
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      gutenprint
      gutenprintBin
      hplip
      epson-escpr
      samsung-unified-linux-driver
    ];
  };

  # Enable automatic printer discovery
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Install printing-related packages
  environment.systemPackages = with pkgs; [
    system-config-printer
  ];
}
