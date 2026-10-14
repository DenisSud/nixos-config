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

    # `pi` — Pi coding agent, taken from the upstream flake instead of the
    # nixpkgs `pi-coding-agent` package (which is bumped by a bot and lags
    # weeks behind). `main` carries every release plus unreleased fixes;
    # release tags are not pinned here because their Nix build can fail
    # upstream (v1.2.0 did — esbuild missing from the install lock), which is
    # also why upstream's `stable` branch lags a release behind.
    # Bump: `nix flake update pi && nh os switch`.
    pi = {
      url = "github:earendil-works/pi/main";
      # Reuse our nixpkgs for both of upstream's nixpkgs inputs; the darwin
      # one only feeds the x86_64-darwin package, which is never built here.
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-darwin-x64.follows = "nixpkgs";
    };
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
