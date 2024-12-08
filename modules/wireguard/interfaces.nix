{ config, lib, ... }:
with lib;
{
  options.networking.vpn = {
    nl-mlv = {
      enable = mkEnableOption "Netherlands MLVault WireGuard interface";
      privateKeyFile = mkOption {
        type = types.str;
        default = "/etc/wireguard/nl-mlv-private";
        description = "Path to the private key file";
      };
    };
    us = {
      enable = mkEnableOption "US Free WireGuard interface";
      privateKeyFile = mkOption {
        type = types.str;
        default = "/etc/wireguard/us-private";
        description = "Path to the private key file";
      };
    };
  };

  config = {
    networking.wg-quick.interfaces = {
      nl-mlv = mkIf config.networking.vpn.nl-mlv.enable {
        address = [ "10.73.176.149/32" "fc00:bbbb:bbbb:bb01::a:b094/128" ];
        dns = [ "100.64.0.4" ];
        privateKeyFile = config.networking.vpn.nl-mlv.privateKeyFile;
        peers = [
          {
            publicKey = "UrQiI9ISdPPzd4ARw1NHOPKKvKvxUhjwRjaI0JpJFgM=";
            allowedIPs = [ "0.0.0.0/0" "::/0" ];
            endpoint = "193.32.249.66:51820";
          }
        ];
      };

      us = mkIf config.networking.vpn.us.enable {
        address = [ "10.2.0.2/32" ];
        dns = [ "10.2.0.1" ];
        privateKeyFile = config.networking.vpn.us.privateKeyFile;
        peers = [
          {
            publicKey = "gucaLaM/mgJQbHVvnZNtW+1L4Mi7E2mtTMrhS0K4miU=";
            allowedIPs = [ "0.0.0.0/0" ];
            endpoint = "146.70.230.146:51820";
            persistentKeepalive = 25;
          }
        ];
      };
    };
  };
}
