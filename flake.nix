{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";

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
    extraSpecialArgs = {inherit inputs;};
      modules = [
        ./configuration.nix
        inputs.stylix.nixosModules.stylix
      ];
    };

  };
}
