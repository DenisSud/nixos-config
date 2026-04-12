---
name: nix-flakes
description: Creates reproducible builds, manages flake inputs, defines devShells, and builds packages with flake.nix. Use when initializing Nix projects, locking dependencies, or running nix build/develop commands.
---
# Nix Flakes
Modern Nix project management with hermeticity and reproducibility through flake.lock.

## Core Commands
### Project Management
```bash
# Initialize a new flake in the current directory
nix flake init
# Update flake.lock (updates all inputs)
nix flake update
# Update specific input only
nix flake update nixpkgs
# Lock without updating (create missing entries)
nix flake lock
# Check flake for syntax and common errors
nix flake check
# Show flake outputs
nix flake show
# Show flake metadata (inputs, revisions)
nix flake metadata path:.
```

### Running and Building
Always prefix local flake paths with `path:` (e.g., `path:.`) to ensure Nix uses all files in the directory without requiring them to be staged in Git.
```bash
nix build path:.               # build default package
nix build path:.#packageName   # build specific output
nix run path:.                 # run default app
nix run path:.#appName         # run specific app
nix run github:numtide/treefmt # run from remote flake
```

### Development Environments
In a headless environment, use `nix develop` with `--command` to run tasks within the environment.
```bash
nix develop path:. --command make build
nix develop path:. --command env
```

---

## Initializing from Templates

### Upstream templates (language baselines)
`the-nix-way/dev-templates` covers standard language environments:
```bash
nix flake init --template "https://flakehub.com/f/the-nix-way/dev-templates/*#${ENV}"
# or
nix flake init -t github:the-nix-way/dev-templates#${ENV}
```
Common `${ENV}` values: `rust`, `python`, `go`, `node`, `ruby`, `java`, `scala`, `elixir`, `haskell`, `zig`, `c-cpp`, `gleam`, `php`, `purescript`

### Local templates (project archetypes)
Local templates live at `~/.pi/agent/skills/nix-flakes/templates/`. Check these first before reaching for upstream — they encode project-specific decisions that upstream templates won't have.

```bash
# See what's available
nix flake show path:~/.pi/agent/skills/nix-flakes/templates

# Initialize from a local template
nix flake init -t path:~/.pi/agent/skills/nix-flakes/templates#django
nix flake init -t path:~/.pi/agent/skills/nix-flakes/templates#python-ml

# Then update to fresh inputs
nix flake update
```

Each template directory contains a `flake.nix` and a `.envrc` with `use flake`. After initializing, update inputs to get fresh lockfile unless the template pins for a specific reason.

### Template directory structure
```
templates/
├── flake.nix          ← root flake declaring all templates as outputs
├── django/
│   ├── flake.nix
│   └── .envrc         ← contains: use flake
├── python-ml/
│   ├── flake.nix
│   └── .envrc
└── rust-wasm/
    ├── flake.nix
    └── .envrc
```

The root `flake.nix` enumerates all subdirectories as template outputs:
```nix
{
  description = "Local flake templates";
  outputs = { self }: {
    templates = {
      django = {
        path = ./django;
        description = "Django + postgres + redis dev environment";
      };
      python-ml = {
        path = ./python-ml;
        description = "Python ML stack with CUDA and uv";
      };
    };
  };
}
```

### Saving a new local template
When you've set up a flake that required non-obvious decisions, save it so future projects can use `-t` to initialize from it.

Name after the archetype, not the project: `django`, `python-ml`, `rust-wasm`, `ml-cuda`.

All four steps are required — don't skip the last two:

```bash
TEMPLATES=~/.pi/agent/skills/nix-flakes/templates

# 1. Create the archetype directory and copy the flake
mkdir -p $TEMPLATES/<archetype>
cp flake.nix $TEMPLATES/<archetype>/

# 2. Add .envrc — every template must have this
echo "use flake" > $TEMPLATES/<archetype>/.envrc

# 3. Register in the root flake so `nix flake init -t` can find it
#    Edit $TEMPLATES/flake.nix and add inside the templates = { ... } block:
#
#    <archetype> = {
#      path = ./<archetype>;
#      description = "One line: what this solves that upstream doesn't";
#    };

# 4. Verify it shows up
nix flake show path:$TEMPLATES
```

The description in the root flake is what appears in `nix flake show` — make it specific enough to distinguish at a glance.

---

## Flake Structure (`flake.nix`)
```nix
{
  description = "A basic flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };
  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      packages.${system}.default = pkgs.hello;
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [ pkgs.git pkgs.vim ];
      };
    };
}
```

## Best Practices
- **Locking**: Commit `flake.lock` to ensure reproducibility across machines.
- **Purity**: Flakes can only access tracked files. Use `path:.` to bypass git tracking during development.
- **Non-Interactive**: When using `nix develop`, always use `--command` to keep scripts non-interactive.

## Debugging
```bash
nix flake metadata path:.
nix eval path:.#packages.x86_64-linux.default.name
```

## Related Skills
- **nix**: Run applications without installation and create development environments using Nix.
- **nh**: Manage NixOS and Home Manager operations with improved output using nh.

## Related Tools
- **search-nix-packages**: Search for packages available in the NixOS package repository.
- **search-nix-options**: Find configuration options available in NixOS.
- **search-home-manager-options**: Find configuration options for Home Manager.
