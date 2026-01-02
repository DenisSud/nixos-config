# AGENTS.md - Agentic Coding Guidelines for NixOS Configuration

This document provides guidelines for agentic coding agents working on this NixOS configuration repository.

## Build/Lint/Test Commands

### Primary Build Commands
- **Full system switch**: `nh os switch` - Build and activate new configuration, make it boot default
- **Test configuration**: `nh os test` - Build and activate configuration without making it boot default
- **Build only**: `nh os build` - Build configuration without activating
- **VM build**: `nh os build-vm` - Build NixOS VM image for testing

### Formatting and Linting
- **Format Nix files**: `nix fmt` - Reformat all Nix files in the standard style
- **Home Manager switch**: `nh home switch` - Apply home-manager configuration

### Single Test Commands
- **Build specific host**: `nh os build --hostname pc` or `nh os build --hostname g14`
- **Test specific host**: `nh os test --hostname pc`
- **Dry run**: `nh os build --dry` - Show what would be built without actually building

### Cleanup
- **Clean generations**: `nh clean all` - Remove old generations and cleanup

## Code Style Guidelines

### Nix Files (.nix)

#### General Structure
- Use 2-space indentation consistently
- Group related configurations with clear section comments using `=============================`
- Use descriptive section headers with emojis for visual organization
- Example:
  ```nix
  # ==============================
  # 🌐  Networking
  # ==============================
  ```

#### Naming Conventions
- Use lowercase with underscores for variable names: `networking.hostName`
- Use camelCase for attribute names within sets: `boot.kernelParams`
- Module files: `snake_case.nix` (e.g., `pc-config.nix`, `home.nix`)
- Host-specific modules: `{hostname}-config.nix` and `{hostname}-hardware-configuration.nix`

#### Imports and Modules
- Keep imports minimal and organized
- Use relative paths for local modules: `./modules/pc-config.nix`
- Group imports logically (core settings, hardware, services, etc.)

#### Configuration Organization
- Separate concerns into modules:
  - `configuration.nix` - Base system configuration
  - `modules/{hostname}-config.nix` - Host-specific settings
  - `modules/{hostname}-hardware-configuration.nix` - Hardware-specific configuration
  - `modules/home.nix` - Home Manager configuration

#### Package Lists
- Group packages by category with comments
- Use `with pkgs;` for package references
- Example:
  ```nix
  environment.systemPackages = with pkgs; [
    # System essentials
    git
    curl
    # Development tools
    neovim
  ];
  ```

#### Services Configuration
- Use consistent enable patterns: `services.serviceName.enable = true;`
- Group related service configurations together
- Document non-obvious configurations with comments

### Lua Files (.lua)

#### Indentation and Formatting
- Use 2-space indentation
- Configure Neovim with:
  ```lua
  vim.o.expandtab = true
  vim.o.tabstop = 2
  vim.o.shiftwidth = 2
  vim.o.softtabstop = 2
  ```

#### Plugin Configuration
- Use Lazy.nvim for plugin management
- Group related plugins and configurations
- Use consistent keymap patterns
- Document plugin purposes and keybindings

#### LSP and Language Server Setup
- Configure LSP servers in dedicated sections
- Use consistent diagnostic and completion settings
- Enable inlay hints and other helpful features

### TOML Files (.toml)

#### Structure
- Use clear section headers with comments
- Group related settings logically
- Example:
  ```toml
  # DIRECTORY - compact path
  [directory]
  format = "[$path]($style) "
  truncation_length = 3
  ```

#### Naming
- Use lowercase with underscores for section names
- Use descriptive variable names
- Add comments explaining non-obvious settings

### General Code Style

#### Comments
- Use `#` for single-line comments in Nix
- Use `--` for single-line comments in Lua
- Use `#` for comments in TOML
- Write descriptive comments for complex configurations
- Document the purpose of custom settings

#### Error Handling
- Validate configurations with `nh os build` before committing
- Test configurations with `nh os test` when possible
- Check for syntax errors with `nix-instantiate --parse`

#### Security
- Never commit secrets or sensitive information
- Use proper file permissions for sensitive files
- Follow principle of least privilege for user accounts

#### Git Practices
- Commit logical units of change
- Use descriptive commit messages
- Test configurations before pushing
- Use `nh os build` to validate changes

### File Organization

#### Repository Structure
```
.
├── configuration.nix              # Base system configuration
├── flake.nix                      # Flake definition
├── flake.lock                     # Flake lock file
├── modules/
│   ├── home.nix                   # Home Manager configuration
│   ├── pc-config.nix              # PC-specific configuration
│   ├── g14-config.nix             # G14-specific configuration
│   ├── pc-hardware-configuration.nix
│   └── g14-hardware-configuration.nix
├── dotfiles/
│   ├── nvim/
│   │   └── init.lua               # Neovim configuration
│   └── starship.toml              # Starship prompt configuration
└── wallpaper.png                  # System wallpaper
```

#### Module Conventions
- Each host gets its own config and hardware modules
- Shared configurations go in `configuration.nix`
- Home Manager settings in `modules/home.nix`
- Dotfiles in `dotfiles/` directory

### Development Workflow

1. **Make Changes**: Edit configuration files following style guidelines
2. **Format**: Run `nix fmt` to format Nix files
3. **Test**: Use `nh os build` to validate configuration
4. **Commit**: Commit changes with descriptive messages
5. **Deploy**: Use `nh os switch` to apply changes (requires root/sudo)

### Common Patterns

#### Conditional Configuration
```nix
# Use lib.mkIf for conditional configurations
{ config, lib, ... }:
{
  config = lib.mkIf (config.networking.hostName == "pc") {
    # PC-specific configuration
  };
}
```

#### Module Imports
```nix
imports = [
  ./modules/pc-config.nix
  ./modules/pc-hardware-configuration.nix
];
```

#### Service Configuration
```nix
services = {
  serviceName = {
    enable = true;
    # additional configuration
  };
};
```

### Tools and Dependencies

#### Required Tools
- `nh` (Nix Helper) - Enhanced nixos-rebuild
- `git` - Version control
- `neovim` - Primary editor (configured in dotfiles)
- `fish` - Default shell

#### Optional Tools
- `lazygit` - TUI Git client
- `ripgrep` - Fast text search
- `fd` - Fast file finder
- `eza` - Enhanced ls command

This document should be updated as the codebase evolves and new patterns emerge.