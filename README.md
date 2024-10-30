nixos/
├── flake.nix          # Main entry point
├── flake.lock         # Lock file for dependencies
│
├── hosts/             # Host-specific configurations
│   └── g14/          # Your laptop config
│       ├── default.nix       # Main host config
│       └── hardware.nix      # Hardware-specific settings
│
├── home/              # Home-manager configurations
│   ├── default.nix           # Main home-manager config
│   ├── terminal/            # Terminal-related configs
│   │   ├── default.nix
│   │   ├── nushell.nix
│   │   ├── starship.nix
│   │   └── zellij.nix
│   │
│   └── programs/           # Application configs
│       ├── default.nix
│       ├── browsers.nix
│       ├── development.nix
│       ├── gaming.nix
│       └── media.nix
│
├── modules/           # NixOS modules
│   ├── core/              # Core system configuration
│   │   ├── default.nix
│   │   ├── nix.nix       # Nix package manager settings
│   │   └── users.nix     # User management
│   │
│   ├── hardware/         # Hardware-related modules
│   │   ├── default.nix
│   │   ├── nvidia.nix
│   │   └── audio.nix
│   │
│   ├── services/        # System services
│   │   ├── default.nix
│   │   ├── docker.nix
│   │   └── ssh.nix
│   │
│   └── desktop/         # Desktop environment
│       ├── default.nix
│       └── gnome.nix
│
├── overlays/          # Custom package overlays
│   └── default.nix
│
└── pkgs/             # Custom packages
    └── default.nix
