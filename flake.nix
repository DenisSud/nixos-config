{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    stylix.url = "github:danth/stylix";
    home-manager = {
        url = "github:nix-community/home-manager";
        inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations = {
      g14 = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [
          ./hosts/g14/configuration.nix
          inputs.nixos-hardware.nixosModules.asus-zephyrus-ga401 # Hardware config
          inputs.home-manager.nixosModules.default # App config
          inputs.stylix.nixosModules.stylix # Linux ricing
        ];
      };

      pi5 = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = {inherit inputs;};
        modules = [
          ./hosts/pi5/configuration.nix
          inputs.nixos-hardware.nixosModules.raspberry-pi-5 # Hardware config
          inputs.home-manager.nixosModules.default
        ];
      };
    };
  };
}
# NixOS Configuration

This repository contains my NixOS configuration files for both my desktop (g14) and my Raspberry Pi 5.

## Usage

To use this configuration, you need to have NixOS installed on your system. Then, you can apply the configuration by running the following command:

```bash
nixos-rebuild switch --flake .#g14
```

For the Raspberry Pi 5, you can apply the configuration by running:

```bash
nixos-rebuild switch --flake .#pi5
```

## Included Packages

### Development Tools
- **dive**: A tool for exploring a container image, layer contents, and discovering vulnerabilities
- **starship**: A minimal, blazing-fast, and infinitely customizable prompt for any shell
- **podman-tui**: A terminal user interface for Podman
- **aider-chat**: A CLI chat interface for AI models
- **docker-compose**: A tool for defining and running multi-container Docker applications
- **fabric-ai**: A tool for AI model deployment
- **ripgrep**: A line-oriented search tool that recursively searches your current directory for a regex pattern
- **kaggle**: A command-line tool for interacting with Kaggle
- **lazygit**: A simple terminal UI for git commands
- **git-lfs**: Git extension for versioning large files
- **zoxide**: A smarter cd command
- **harper**: A tool for managing and querying data
- **rip2**: A tool for converting rip files to other formats
- **bat**: A cat(1) clone with syntax highlighting and Git integration
- **tor**: An anonymizing overlay network for TCP

### Shell Utilities
- **xclip**: Command-line interface to the X11 clipboard
- **carapace**: A command-line shell autocompletion
- **pandoc**: A universal document converter
- **nmap**: A network exploration tool and security/port scanner
- **tree**: A directory listing program that produces a depth-indented listing of files

### Program Configurations
- **bat**: A cat(1) clone with syntax highlighting and Git integration
- **btop**: A resource monitor that shows usage and stats for processor, memory, disks, network and processes
- **lazygit**: A simple terminal UI for git commands
- **ghostty**: A terminal emulator that supports true color and other features
- **neovim**: A highly configurable text editor built to enable effective text editing

## Additional Information

This configuration uses the following inputs:
- **nixpkgs**: The Nix Packages collection
- **nixos-hardware**: Hardware-specific configuration modules
- **home-manager**: A system for managing user environments
- **stylix**: A Linux ricing tool

For more information, please refer to the respective repositories.

## License

This configuration is licensed under the MIT License. See the LICENSE file for more details.
