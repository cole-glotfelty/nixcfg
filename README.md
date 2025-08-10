# Cole Glotfelty's NixOS Configuration (V2)

Modular NixOS/nix-darwin configuration using flakes with integrated Home Manager.

## Systems
- **Linux**: `casper` (main desktop), `melchior` (secondary)
- **macOS**: `alpha-1-5`

## Structure
```
├── flake.nix              # System definitions and inputs
├── hosts/                 # System-level configuration
│   ├── features/          # Modular system features 
│   └── {hostname}/        # Host-specific configs
├── home/                  # Home Manager configuration
│   ├── features/          # Modular user features
│   └── {platform}/{user}/ # User-specific configs
├── lib/                   # Extended library functions
└── scripts/               # Build and maintenance scripts
```

## Configuration Pattern
- **Host modules**: System services, hardware, security
- **Home modules**: User applications, dotfiles, desktop environment
- **Home-driven features**: Some host modules auto-enable when users enable corresponding home features
- **Modular design**: Feature-based toggles for easy customization

## Usage
```bash
just rebuild     # Rebuild system
nix flake check  # Validate config
```

See [CLAUDE.md](./CLAUDE.md) for detailed documentation.
