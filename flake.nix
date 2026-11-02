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
    #
    # Pinned to a rev instead of `main` for now: main's own Nix package does
    # not evaluate since 1.5.0 added @earendil-works/pi-schema to the install
    # lock without an integrity hash and nix/package.nix has no
    # packageSourceOverrides entry for it (upstream #11682, fix in PR #11685).
    # Go back to `main` once that merges. 177e2ad is the last rev before the
    # 1.5.0 bump and also builds 1.4.0, so nothing is lost in the meantime.
    pi = {
      url = "github:earendil-works/pi/177e2ad7e41e85c16c859f844a0569a3c76f2666";
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
