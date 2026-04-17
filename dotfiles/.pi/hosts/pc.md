# PC (Desktop)

Primary desktop machine running NixOS.

## Hardware

| Component | Details |
|-----------|---------|
| **CPU** | AMD Ryzen 5 9600X (6-core/12-thread) @ 5.49 GHz |
| **GPU** | NVIDIA GeForce RTX 5070 (Discrete) |
| **VRAM** | 12 GB GDDR7 |
| **Memory** | 32 GB DDR5 |
| **Storage** | Samsung 990 EVO Plus 1TB NVMe (931 GB) |
| **Display** | LG Electronics 27" (2560x1440, 144 Hz, External) |
| **LAN** | 192.168.1.20/24 (eno1) |

## Software

| Component | Version/Details |
|-----------|-----------------|
| **OS** | NixOS 26.05 (Yarara) x86_64 |
| **Kernel** | Linux 7.0.0 |
| **Desktop** | GNOME 49.4 (Wayland) |
| **Window Manager** | Mutter (Wayland) |
| **Shell** | Fish (pi shell when using agent) |
| **Terminal** | Ghostty 1.3.1 |
| **Terminal Font** | JetBrainsMono Nerd Font Mono (12pt) |
| **NVIDIA Driver** | 595.58.03 (Open Kernel Module) |
| **CUDA** | 13.2 |

## NixOS Configuration

- **Config location**: `/home/denis/nixos-config/`
- **Flake**: `flake.nix` with `pc` and `g14` configurations
- **Base config**: `configuration.nix` (shared between hosts)
- **Host config**: `modules/pc-config.nix`
- **Hardware config**: `modules/pc-hardware-configuration.nix`
- **Home Manager**: `modules/home.nix`

### Key Configuration Details

- Boot: systemd-boot with EFI
- Graphics: NVIDIA open kernel module, video driver `nvidia`
- Ollama: Enabled and exposed to LAN (0.0.0.0)
- Docker: Enabled
- Audio: PipeWire with ALSA and Pulse support
- Firewall: Disabled
- Time zone: Europe/Moscow
- Locale: en_US.UTF-8 (with ru_RU.UTF-8 additional)

## Dotfiles

- **Location**: `/home/denis/nixos-config/dotfiles/`
- **Neovim**: `dotfiles/nvim/init.lua` → `~/.config/nvim`
- **Starship**: `dotfiles/starship.toml` → `~/.config/starship.toml`
- **Pi Agent**: `dotfiles/.pi/agent/` → `~/.pi/agent/`

## Running Services

- NVIDIA driver processes: gnome-shell (163MB), Xwayland (4MB), ghostty (168MB)
- Ollama server on port 11434 (accessible via LAN)
- Xray proxy service (systemd)
- Docker daemon

## System Resources

- Memory: 5 GB / 30.99 GB (16%)
- Swap: 254 MB / 8.8 GB (3%)
- Disk: 297 GB / 906 GB (33%)
- GPU Memory: 657 MB / 12.2 GB (5%)
- GPU Utilization: 2%
- Power: 10W / 250W

## Notes for AI Agent

This is the **primary desktop machine** — use this for:
- Development work requiring GPU (CUDA, ML, etc.)
- Ollama experiments (served on LAN)
- General NixOS development/testing

The NixOS config is managed declaratively via flakes. Any system changes should be made in the appropriate module file, then applied with `sudo nixos-rebuild switch --flake .#pc`.

Dotfiles are linked via Home Manager — do not edit symlinked files directly; edit the source in `dotfiles/` instead.