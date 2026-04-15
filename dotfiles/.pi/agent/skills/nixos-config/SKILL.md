---
name: nixos-config
description: Manage and edit the NixOS configuration and dotfiles. Use whenever the user asks to change system packages, services, desktop settings, user packages, shell config, neovim, ghostty, starship, fonts, NVIDIA, Docker, Ollama, or any other NixOS or Home Manager setting. Also use when the user mentions rebuilding, switching, or checking the config.
---

# NixOS Configuration

This machine runs NixOS — an immutable, declarative Linux distribution. The entire system is defined in a single Git repo at `/home/denis/nixos-config`.

## Principles

- **No traditional package managers.** Never suggest `apt`, `yum`, `dnf`, `pacman`, `npm install -g`, or `cargo install` for system-wide binaries.
- **One-off tools:** Use `nix shell nixpkgs#<pkg>` or `nix run nixpkgs#<pkg>`. If unsure of the attribute name, use `nix search nixpkgs <query>`.
- **Project repos:** If the working directory has a `flake.nix`, treat it as the source of truth. Add dependencies by editing `flake.nix` (e.g. `buildInputs`, `nativeBuildInputs`, or shell `packages`), then `nix develop` to reload. Never bypass a flake with ad-hoc installs.
- **Dotfiles managed by Home Manager:** Files declared in `home.file` are symlinked from the Nix store, not from the repo directly. Always edit the source in the config repo, then rebuild — never edit the symlink targets in `~/` (they get overwritten on rebuild).
- **Hardware configs** (`*-hardware-configuration.nix`) are auto-generated — **DO NOT EDIT THEM**.
- **Declarative mindset:** Prefer solutions that preserve reproducibility. If something isn't in nixpkgs, flag it and suggest the cleanest nix-native approach (e.g. `pkgs.python3.withPackages`, a custom derivation, or `flake-parts`).

## Repo Layout

```
nixos-config/
├── flake.nix                          # Flake entry — defines both hosts
├── flake.lock
├── configuration.nix                  # Shared system config (packages, services, fonts, programs)
├── modules/
│   ├── home.nix                       # Home Manager for user denis (fish, ghostty, fzf, direnv, dotfile symlinks)
│   ├── pc-config.nix                  # PC-specific: hostname, kernel, NVIDIA RTX 5070, xray service, DDC brightness extension
│   ├── pc-hardware-configuration.nix  # DO NOT EDIT
│   ├── g14-config.nix                 # G14-specific: hostname, NVIDIA/AMD hybrid, prime offload
│   └── g14-hardware-configuration.nix  # DO NOT EDIT
├── dotfiles/
│   ├── nvim/init.lua                  # Neovim config (lazy.nvim, treesitter, LSP, conform, etc.)
│   ├── starship.toml                  # Starship prompt config
│   └── .pi/agent/                     # Pi agent config (settings, themes, extensions, skills)
```

## Hosts

Two hosts are defined in `flake.nix`:

### pc (`.#pc`)
- **Hardware:** AMD, NVIDIA RTX 5070 (open kernel modules)
- **Key host-specific:** Linux latest kernel, IP forwarding, xray proxy service, Ollama CUDA + open firewall for LAN
- **Rebuild:** `sudo nixos-rebuild switch --flake .#pc`

### g14 (`.#g14`)
- **Hardware:** ASUS ROG Zephyrus G14, AMD + NVIDIA RTX 3050 Mobile (hybrid prime offload)
- **Key host-specific:** Proprietary NVIDIA driver, `nvidiaSettings`, amdgpu + nvidia video drivers
- **Rebuild:** `sudo nixos-rebuild switch --flake .#g14`

### Shared config (`configuration.nix`)
Both hosts inherit: GNOME + GDM, PipeWire audio, Docker, SSH, Flatpak, Fish shell, fonts, system packages, LSP servers, formatters, Steam, nh, appimage support, GPG agent.

## Where to Edit What

| Target | File |
|--------|------|
| System packages, services, fonts, programs | `configuration.nix` |
| Host-specific (hostname, kernel, GPU, systemd services) | `modules/<host>-config.nix` |
| User packages (GUI apps, CLI tools) | `configuration.nix` → `users.users.denis.packages` |
| Shell config, terminal, prompt, direnv | `modules/home.nix` |
| Neovim | `dotfiles/nvim/init.lua` |
| Starship | `dotfiles/starship.toml` |
| Pi agent (settings, themes, skills) | `dotfiles/.pi/agent/` |
| Arbitrary dotfiles symlinked into `~/` | `modules/home.nix` → `home.file` + source in `dotfiles/` |
| Hardware config | **Never** — auto-generated |

## Adding a Package

1. **System-wide:** Add to `environment.systemPackages` in `configuration.nix`
2. **User-only:** Add to `users.users.denis.packages` in `configuration.nix`
3. **Home Manager managed** (when the module provides config/options): Add `programs.<name>.enable = true` in `modules/home.nix` — the module installs the package automatically, so do **not** also add it to `users.users.denis.packages`
4. **One-off:** `nix shell nixpkgs#<pkg>` — no config change needed

## Dotfile Symlinks

`home.file` entries in `modules/home.nix` symlink files from the Nix store into `~/`. Example:

```nix
home.file.".config/nvim".source = ../dotfiles/nvim;
```

**Workflow:** edit the source file in `dotfiles/` → rebuild → the symlink in `~/` updates automatically. Never edit the symlink target directly.

## Validation

After any config change:

```bash
nix flake check                          # Syntax & build check (no rebuild)
sudo nixos-rebuild switch --flake .#pc    # Apply changes (use appropriate host)
```

Always run `nix flake check` first. Only rebuild if it passes.