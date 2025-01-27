{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    stylix.url = "github:danth/stylix";
    home-manager = {
        url = "github:nix-community/home-manager";
        inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations = {
      g14 = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [
          ./hosts/g14/configuration.nix
          inputs.nixos-hardware.nixosModules.asus-zephyrus-ga401 # Hardware config
          inputs.home-manager.nixosModules.default # App config
          inputs.stylix.nixosModules.stylix # Linux ricing
        ];
      };

      pi5 = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = {inherit inputs;};
        modules = [
          ./hosts/pi5/configuration.nix
          inputs.nixos-hardware.nixosModules.raspberry-pi-5 # Hardware config
          inputs.home-manager.nixosModules.default
        ];
      };
    };
  };
}
