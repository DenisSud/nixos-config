{ config, lib, pkgs, ... }:

{
  services.openssh = {
    enable = true;
    settings = {
      # Forbid root login through SSH.
      PermitRootLogin = "no";
      # Use keys only. Remove if you want to SSH using password (not recommended)
      PasswordAuthentication = false;
      # Enable X11 forwarding
      X11Forwarding = true;
    };

    # List of authorized keys
    extraConfig = ''
      AllowUsers denis
    '';
  };

  # SSH port
  networking.firewall = {
    allowedTCPPorts = [ 22 ];
    allowedUDPPorts = [ 22 ];
  };

  # Add your SSH public key here
  users.users.denis.openssh.authorizedKeys.keys = [
    "ssh-ed25539 AAAAC3Nxxxxx ryan@xxx"  # Replace with your key
  ];
}
