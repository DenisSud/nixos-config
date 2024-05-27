{
  description = "Flake for building my gnome system";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master"

    asusctl.url = "github:soulsoiledit/nixpkgs-asusctl-5.0.10/asusctl-5.0.10"

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };


  };

  outputs = inputs@{ nixpkgs, home-manager, asusctl, nixos-hardware, ... }: {
    let 
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in 
    { 
      
      nixosConfigurations.default = {
        specialArgs = {inherit inputs;};
        modules = [
          ./configuration.nix
          /etc/nixos/hardware-configuration.nix
          <nixos-hardware/asus/zephyrus/ga401>
          ./packages.nix

          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users = {
                denis = import ./home.nix;
              };
            };
          }

        ];


      };
    };

  };


}
