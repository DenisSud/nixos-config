{ config, lib, pkgs, ... }:

{
  virtualisation = {
    docker = {
      enable = true;
      enableNvidia = true;
      extraOptions = "--default-runtime=nvidia";

      daemon.settings = {
        "data-root" = "/home/denis/Docker";
      };

      # Automatically prune Docker resources
      autoPrune = {
        enable = true;
        dates = "daily";
        flags = [ "--all" "--volumes" ];
      };
    };

    # Enable Nvidia Container Toolkit
    nvidia-container-toolkit.enable = true;
  };

  # Add user to docker group
  users.users.denis.extraGroups = [ "docker" ];

  # Install docker-related packages
  environment.systemPackages = with pkgs; [
    docker-compose
    lazydocker    # Terminal UI for Docker
    ctop          # Container metrics and monitoring
  ];
}
