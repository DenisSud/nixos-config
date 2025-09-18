 {
  description = "My NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05"; # Or a specific branch
    # home-manager.url = "github:nix-community/home-manager"; # Optional
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations = {
      # Replace "hostname" with your system's hostname
      g14 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux"; # System architecture
	specialArgs = { inherit inputs; }; # Pass inputs to modules
        modules = [
          ./configuration.nix # Your existing configuration
          ./hardware-configuration.nix # Include if needed
          # home-manager.nixosModules.home-manager # Optional
        ];
      };
    };
  };
}
