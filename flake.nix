{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    stylix.url = "github:danth/stylix";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs:
  {
    nixosConfigurations = {
      g14 = nixpkgs.lib.nixosSystem {
        modules = [
          ./hosts/g14/configuration.nix
          inputs.nixos-hardware.nixosModules.asus-zephyrus-ga401 # Hardware config
          inputs.home-manager.nixosModules.default # App config
          inputs.stylix.nixosModules.stylix # Stylix config
        ];
      };
    };
  };
}
