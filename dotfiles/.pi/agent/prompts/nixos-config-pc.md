NixOS config for the **pc** host at `/home/denis/nixos-config`.

Read these files for current state:
- `configuration.nix` — shared system config, packages, services
- `modules/pc-config.nix` — pc-specific config
- `modules/home.nix` — Home Manager for user `denis`
- `modules/pc-hardware-configuration.nix` — do not edit

- **Rebuild:** `sudo nixos-rebuild switch --flake .#pc`
- **Check:** `nix flake check`