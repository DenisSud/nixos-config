{ config, lib, pkgs, ... }:

{
  # Enable bluetooth and blueman for management
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
      };
    };
  };

  services.blueman.enable = true;

  # Add necessary packages for bluetooth
  environment.systemPackages = with pkgs; [
    bluez
    bluez-tools
  ];

  # Enable bluetooth related services
  systemd.services.bluetooth = {
    enable = true;
    description = "Bluetooth service";
    serviceConfig = {
      Type = "dbus";
      BusName = "org.bluez";
      ExecStart = "${pkgs.bluez}/libexec/bluetooth/bluetoothd";
    };
    wantedBy = [ "bluetooth.target" ];
  };
}
