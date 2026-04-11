# NixOS Configuration — Project Context

## Overview
This repo contains the NixOS system configuration for two machines:
- **pc** — Desktop with AMD CPU + NVIDIA RTX 5070 (Blackwell, open driver)
- **g14** — ASUS ROG Zephyrus G14 laptop with AMD CPU + NVIDIA hybrid graphics

## Architecture: 
```
/home/denis/nixos-config
├── flake.nix # Flake entry point, defines both hosts
├── configuration.nix # Shared config (bootloader, GNOME, audio, users, base packages)
├── modules
│   ├── pc-hardware-configuration.nix # Desktop hardware (generated, don't edit)
│   ├── pc-config.nix # Desktop-specific: hostname, NVIDIA, xray proxy, ollama, IP forwarding
│   ├── g14-hardware-configuration.nix # Laptop hardware (generated, don't edit)
│   ├── g14-config.nix # Laptop-specific: hostname, NVIDIA hybrid
│   └── home.nix # Home Manager config for 'denis' user
└── dotfiles
    ├── nvim
    │   └── init.lua
    ├── starship.toml
    └── pi/ # Pi coding agent configuration: skills, extensions, system prompts and more
```

## Key Facts
- **User:** denis
- **Shell:** fish (with starship, zoxide, fzf, eza aliases)
- **Terminal:** Ghostty
- **Editor:** Neovim (kickstart-style config via lazy.nvim)
- **OS:** NixOS unstable (nixos-unstable channel via flake)
- **Desktop:** GNOME + GDM
- **Audio:** PipeWire
- **NVIDIA:** Open kernel module enabled on both machines
- **Home Manager:** Integrated as NixOS module (not standalone)

## NixOS-Specific Rules
- **Never** suggest `apt`, `yum`, `dnf`, or `pacman` commands
- **Never** suggest `npm install -g` or `cargo install` for system-wide binaries — use nix packages instead
- Packages must be added to `environment.systemPackages`, `users.users.denis.packages`, or `home.packages` in home.nix
- After editing nix files, rebuild with `sudo nixos-rebuild switch --flake .#pc` (or `.#g14`)
- Hardware configs in `modules/*-hardware-configuration.nix` are auto-generated — do not edit
- Symlinks in `dotfiles/` are managed by Home Manager's `home.file` — edit source files in the repo, not in `~/.config/`
- Neovim config lives at `dotfiles/nvim/init.lua`, NOT at `~/.config/nvim/init.lua`

## Neovim Setup
- Plugin manager: **lazy.nvim**
- Completion: **blink.cmp** with LuaSnip
- LSP: **nvim-lspconfig** with `vim.lsp.config` / `vim.lsp.enable` (Neovim 0.11+ API)
- Treesitter: **nvim-treesitter v1.x** (uses `require("nvim-treesitter").install()`, needs `tree-sitter` CLI in PATH)
- Formatter: **conform.nvim** (stylua, prettier, nixfmt, gofumpt, rustfmt, etc.)
- File explorer: **nvim-tree**
- Git: **gitsigns**, **diffview**, **neogit**
- Fuzzy finder: **telescope** with fzf-native and ui-select
- AI: **supermaven-nvim**
- Mini.nvim: pairs, ai, surround, splitjoin, statusline
- Terminal: **toggleterm** (with vertical claude/pi terminal)

## Build / Rebuild Commands
```bash
# Rebuild the PC host
sudo nixos-rebuild switch --flake /home/denis/nixos-config#pc

# Rebuild the G14 host
sudo nixos-rebuild switch --flake /home/denis/nixos-config#g14

# Check flake
nix flake check /home/denis/nixos-config
```
