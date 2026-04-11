NixOS config for the **g14** host (ASUS ROG Zephyrus G14) at `/home/denis/nixos-config`.

Read these files for current state:
- `configuration.nix` — shared system config, packages, services
- `modules/g14-config.nix` — g14-specific config
- `modules/home.nix` — Home Manager for user `denis`
- `modules/g14-hardware-configuration.nix` — do not edit

- **Rebuild:** `sudo nixos-rebuild switch --flake .#g14`
- **Check:** `nix flake check`