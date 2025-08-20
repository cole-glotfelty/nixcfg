# Cole Glotfelty's NixOS Configuration (V3)

Advanced NixOS/nix-darwin configuration featuring metadata-driven auto-generation, platform-specific user templates, and cross-platform compatibility.

## Systems
- **Linux**: `casper` (main desktop), `melchior` (secondary)
- **macOS**: `alpha-1-5`

## Structure
```
├── flake.nix              # Auto-discovering flake with metadata-driven generation
├── hosts/                 # Host-specific system configuration
│   ├── {hostname}/        # Host configs with _meta and feature toggles
│   │   ├── default.nix    # Host config with _meta (system, architecture, users)
│   │   └── users/         # Host-specific user overrides
│   │       └── {user}.nix # User config with monitor settings, etc.
├── modules/               # Modular feature system
│   ├── common/            # Shared platform configuration
│   ├── nixos/             # NixOS-specific system modules
│   ├── darwin/            # macOS-specific system modules
│   └── home-manager/      # Cross-platform user modules
├── users/                 # User-centric configuration
│   ├── common/            # Shared user configuration (identity, defaults, paths)
│   └── templates/         # Platform-specific user templates
│       └── {user}/        # Per-user template directory
│           ├── default.nix    # Home-manager features
│           ├── home.nix       # Platform-specific settings
│           ├── nixos.nix      # NixOS system user account
│           └── darwin.nix     # macOS system user account
├── libs/                  # Extended library functions
└── pkgs/                  # Custom packages & portable apps
```

## V3 Architecture Highlights
- **Metadata-Driven Auto-Generation**: Hosts declare `_meta`, flake auto-generates all configurations
- **Platform-Specific Templates**: Users have separate `nixos.nix` and `darwin.nix` system configs
- **Cross-Platform Compatibility**: Same user config works on NixOS, macOS, and standalone Home Manager
- **Validation System**: Prevents configuration drift between metadata and actual configs
- **Home-Driven Modules**: Host services auto-enable when users enable corresponding features
- **Standalone-First Apps**: Portable applications (`nix run .#nixvim`) with seamless home-manager integration
- **Consolidated User Organization**: All user-related config under `users/` (common + templates)

## V3 Configuration Pattern
1. **Host metadata** (`_meta`) declares system type, architecture, and users
2. **Platform-specific templates** auto-imported based on host's `_meta.system`
3. **User templates** contain complete platform-specific user configuration
4. **Host user configs** contain only host-specific overrides (monitors, etc.)
5. **Auto-discovery** generates all flake configurations from metadata and filesystem
6. **Validation** prevents configuration drift between metadata and actual configs

## Usage
```bash
just rebuild           # Rebuild system
nix flake check        # Validate configuration and metadata consistency
nix run .#nixvim       # Run portable applications
nix run .#tmux-sessionizer
```

See [CLAUDE.md](./CLAUDE.md) for comprehensive documentation and architecture details.
