{ config, lib, pkgs, ... }:

{
  imports = [
    ./nix.nix
    ./users.nix
  ];

  # Basic system configuration that doesn't fit into other categories
  environment = {
    # List of directories to add to PATH
    systemPackages = with pkgs; [
      # Basic system tools
      git
      vim
      wget
      curl
      btop
      tree
    ];

    # Set default editor to vim
    variables = {
      EDITOR = "vim";
      VISUAL = "vim";
    };

    # Clean up /tmp on boot
    cleanTmpDir = true;
  };

  # Set your time zone.
  time.timeZone = lib.mkDefault "Europe/Moscow";

  # Select internationalisation properties.
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";

  # Security configuration
  security = {
    # Don't allow sudo password timeout
    sudo.enable = true;
    sudo.extraConfig = ''
      Defaults timestamp_timeout=0
    '';

    # Enable polkit for GUI apps that need root
    polkit.enable = true;
  };
}
