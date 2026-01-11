{
  description = "My NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations = {
      pc = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux"; # System architecture
        specialArgs = { inherit inputs; }; # Pass inputs to modules
        modules = [
          inputs.home-manager.nixosModules.default
          inputs.stylix.nixosModules.stylix
          ./configuration.nix
          ./modules/pc-hardware-configuration.nix
          ./modules/pc-config.nix
        ];
      };
      g14 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux"; # System architecture
        specialArgs = { inherit inputs; }; # Pass inputs to modules
        modules = [
          inputs.home-manager.nixosModules.default
          inputs.stylix.nixosModules.stylix
          ./configuration.nix
          ./modules/g14-hardware-configuration.nix
          ./modules/g14-config.nix
        ];
      };
    };
  };
}
