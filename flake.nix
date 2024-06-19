{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    hyprland.url = "github:hyprwm/Hyprland";

    stylix.url = "github:danth/stylix";
  };

  outputs = { self, nixpkgs, ... }@inputs: 
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};  
  in
  {

    nixosConfigurations.default = nixpkgs.lib.nixosSystem {
      modules = [
        ./configuration.nix
        inputs.stylix.nixosModules.stylix
      ];
    };

  };
}
