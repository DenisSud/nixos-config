{
  config,
  pkgs,
  lib,
  ...
}:

{
  # PC-only settings (moved from your old configuration.nix)
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
  };

  networking.hostName = "pc";

  # firewall and extra ports for pc
  networking.firewall.allowedTCPPorts = [
    22
    631
    8080
  ];
  networking.firewall.allowedUDPPorts = [ ];
  networking.firewall.allowPing = false;

  systemd.services.xray = {
    description = "Xray Service";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      ExecStart = "${pkgs.xray}/bin/xray run -c /etc/xray/config.json";
      Restart = "always";
      User = "nobody";
      CapabilityBoundingSet = [
        "CAP_NET_ADMIN"
        "CAP_NET_BIND_SERVICE"
      ];
      AmbientCapabilities = [
        "CAP_NET_ADMIN"
        "CAP_NET_BIND_SERVICE"
      ];
      NoNewPrivileges = true;
    };
  };
  # ==============================
  # 🎮  Hardware & Graphics
  # ==============================
  hardware = {
    i2c.enable = true;
    graphics = {
      enable = true;
      enable32Bit = true;
    };

    nvidia.open = true;
    nvidia-container-toolkit.enable = true;
  };

  fileSystems."/media/Denis" = {
    device = "/dev/disk/by-uuid/68F929974FE7F126";
    fsType = "ntfs-3g";
    options = [
      "rw"
      "nofail"
      "uid=1000"
      "gid=1000"
      "umask=022"
      "allow_other"
    ];
  };

  # ==============================
  # Desktop Environment (GNOME + X11)
  # ==============================
  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];

    xkb = {
      layout = "us";
      variant = "";
    };
  };
  services = {
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };
  services.ollama = {
    host = "0.0.0.0";
    enable = true;
    openFirewall = true;
    package = pkgs.ollama-cuda;
  };
  services.jellyfin.enable = true;
  services.jellyfin.openFirewall = true;

  services.printing.enable = true;

  # any other PC-only things you want to keep separate can go here

  specialisation = {
    gnome.configuration = {
      system.nixos.tags = [ "gnome" ];
    };

  };
}
