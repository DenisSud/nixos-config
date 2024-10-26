{
    description = "Nixos config flake";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
        stylix.url = "github:danth/stylix";
        home-manager.url = "github:nix-community/home-manager";
        home-manager.inputs.nixpkgs.follows = "nixpkgs";
        nixos-hardware.url = "github:NixOS/nixos-hardware/master";
        nixvim = {
            url = "github:nix-community/nixvim";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs = { self, nixpkgs, ... }@inputs:
        let
            system = "x86_64-linux";
            pkgs = nixpkgs.legacyPackages.${system};
        in
            {
            nixosConfigurations.g14 = nixpkgs.lib.nixosSystem {
                inherit system;
                specialArgs = { inherit inputs; };
                modules = [
                    ./configuration.nix
                    inputs.stylix.nixosModules.stylix
                    inputs.nixos-hardware.nixosModules.asus-zephyrus-ga401
                    inputs.home-manager.nixosModules.home-manager
                    inputs.nixvim.nixosModules.nixvim # Import the NixVim module
                ];
            };
        };
}
