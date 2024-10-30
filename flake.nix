{
  description = "NixOS configuration";

  inputs = {
    # Core inputs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hardware support
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # NixVim
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
    nixos-hardware,
    nixvim,
    ...
  } @ inputs: let
    system = "x86_64-linux";

    # Overlays is an array of all the overlays we want to apply
    overlays = [
      # Make unstable packages available through pkgs.unstable
      (final: prev: {
        unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
      })
    ];

    # This lets us reuse the same pkgs config for all hosts
    pkgs = import nixpkgs {
      inherit system overlays;
      config = {
        allowUnfree = true;
      };
    };

    # Common modules shared by all hosts
    defaultModules = [
      # Make home-manager as a module of nixos
      # so that home-manager configuration will be deployed automatically
      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
      }

      # Import nixvim module
      nixvim.nixosModules.nixvim

      # Import our common modules
      ./modules/core
      ./modules/hardware
      ./modules/services
      ./modules/desktop
    ];

  in {
    nixosConfigurations = {
      # My Asus G14 laptop
      g14 = nixpkgs.lib.nixosSystem {
        inherit system pkgs;
        modules = defaultModules ++ [
          # Hardware specific modules
          nixos-hardware.nixosModules.asus-zephyrus-ga401

          # Host specific configuration
          ./hosts/g14

          # Home manager configuration
          {
            home-manager.users.denis = import ./home;
          }
        ];
        # Pass inputs through to modules
        specialArgs = { inherit inputs; };
      };
    };

    # Development shells
    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [
        nil # Nix LSP
        alejandra # Nix formatter
      ];
    };

    # Makes nixos-rebuild work with flakes
    formatter.${system} = pkgs.alejandra;
  };
}
