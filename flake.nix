{
  description = "My NixOS Configuration — functional module layout, two hosts (pc + g14)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # `rip` — Rust file-removal tool, exposed as a system package
    rip = {
      url = "github:cesarferreira/rip";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # NOTE: ASUS laptop support (asusctl + supergfxd) is built into
    # nixpkgs directly via `services.asusd` and `services.supergfxd` —
    # no separate flake input needed.
  };

  outputs =
    {
      self,
      nixpkgs,
      ...
    }@inputs:
    {
      nixosConfigurations = {
        pc = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/pc.nix
            ./hosts/pc-hardware.nix
          ];
        };

        g14 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/g14.nix
            ./hosts/g14-hardware.nix
          ];
        };
      };
    };
}
