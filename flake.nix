{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    stylix.url = "github:danth/stylix";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs:
  {
    nixosConfigurations = {
      g14 = nixpkgs.lib.nixosSystem {
        modules = [
          ./hosts/g14/configuration.nix
          inputs.home-manager.nixosModules.default # App config
          inputs.stylix.nixosModules.stylix # Stylix config
        ];
      };
    };
  };
}
