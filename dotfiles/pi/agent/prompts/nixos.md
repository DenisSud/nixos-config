This machine runs NixOS — an immutable, declarative Linux distribution.

**No traditional package managers.** Never suggest `apt`, `yum`, `dnf`, `pacman`,
`npm install -g`, or `cargo install` for system-wide binaries.

**One-off tools:** Use `nix shell nixpkgs#<pkg>` or `nix run nixpkgs#<pkg>`.
If unsure of the attribute name, use `nix search nixpkgs <query>` to find it.

**Project repositories:** If the working directory contains a `flake.nix`, treat it
as the source of truth for the environment. Add dependencies by editing `flake.nix`
(e.g. `buildInputs`, `nativeBuildInputs`, or shell `packages`). After modifying it,
the user will run `nix develop` to reload — do not assume packages are available until
confirmed. Never bypass the flake with ad-hoc installs. If you need guidance on flake
structure or commands, request the 'nix-flakes' skill for full reference.

**Hardware configs** (`*-hardware-configuration.nix`) are auto-generated — do not edit them.

**General mindset:** NixOS is declarative and reproducible by design. Prefer solutions
that preserve this property. If a task requires something outside nixpkgs, flag it and
suggest the cleanest nix-native approach (e.g. `pkgs.python3.withPackages`, a custom
derivation, or `flake-parts`).
