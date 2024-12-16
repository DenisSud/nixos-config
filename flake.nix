{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    stylix.url = "github:danth/stylix";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations.g14 = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [
        ./hosts/g14/configuration.nix
        inputs.nixos-hardware.nixosModules.asus-zephyrus-ga401 # Hardware
        inputs.home-manager.nixosModules.default # App config
        inputs.stylix.nixosModules.stylix # Linux ricing
      ];
    };
  };
}
