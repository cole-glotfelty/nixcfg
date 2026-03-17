# NixOS Configuration

NixOS/nix-darwin configuration with metadata-driven auto-generation and cross-platform user templates.

## Hosts
| Host | Platform | Architecture |
|------|----------|--------------|
| casper | NixOS | x86_64-linux |
| melchior | NixOS | x86_64-linux |
| alpha-1-5 | Darwin | aarch64-darwin |

## Usage
```bash
sudo nixos-rebuild switch --flake .   # NixOS
darwin-rebuild switch --flake .       # macOS
nix flake check                       # Validate
nix run .#nixvim                      # Portable apps
```

## Structure
```
├── hosts/{hostname}/
│   ├── default.nix          # Host config with _meta (system, arch, users)
│   └── users/{user}.nix     # Host-specific overrides (monitors, etc.)
├── modules/
│   ├── common/              # Shared platform config (nixos/, darwin/)
│   ├── nixos/               # System modules (hardware, wm, security, apps)
│   ├── darwin/              # macOS modules (homebrew)
│   └── home-manager/        # User modules (cli, desktop, applications, style)
├── users/
│   ├── common/              # Shared config (identity, defaults, paths)
│   └── templates/{user}/
│       ├── default.nix      # Home-manager features (cross-platform)
│       ├── home.nix         # Home-manager settings (username, paths)
│       ├── nixos.nix        # NixOS system account definition
│       └── darwin.nix       # macOS system account definition
├── pkgs/                    # Custom packages (nixvim, tmux-sessionizer)
├── libs/                    # Extended lib functions (mkIfAnyHMOpt, etc.)
└── overlays/                # Nixpkgs overlays (additions, unstable-packages)
```

## User Template System

Users are defined once in `users/templates/{user}/` with platform-specific files:
- **default.nix** — Feature toggles and home-manager module imports
- **home.nix** — Username, home directory, user identity
- **nixos.nix** — System user account for NixOS (groups, shell, etc.)
- **darwin.nix** — System user account for macOS

The flake reads each host's `_meta.users` list and automatically imports the correct platform template (`nixos.nix` or `darwin.nix`). Host-specific overrides (like monitor configuration) go in `hosts/{hostname}/users/{user}.nix`.

## Adding a New Host

1. Create `hosts/{hostname}/default.nix` with required `_meta`:
   ```nix
   {
     _meta = {
       system = "nixos";           # or "darwin"
       architecture = "x86_64-linux";
       users = [ "username" ];
     };
     imports = [ ../../modules/common/nixos ];
     features = { /* enable features */ };
   }
   ```
2. Create `hosts/{hostname}/configuration.nix` for hardware config
3. Create `hosts/{hostname}/users/{user}.nix` for each user in `_meta.users`

## Adding a New User

1. Create `users/templates/{user}/` directory with:
   - `default.nix` — Import modules, set feature toggles
   - `home.nix` — Set `home.username`, `home.homeDirectory`, `home.stateVersion`
   - `nixos.nix` — Define `users.users.{user}` (NixOS only)
   - `darwin.nix` — Define `users.users.{user}` (macOS only)
2. Add username to host's `_meta.users` list
3. Create `hosts/{hostname}/users/{user}.nix` with host-specific overrides

> [!NOTE]
> New users using the `messaging.nix` module will have to run `krisp-patcher` once to verify that krisp noise suppression is installed for Discord

## Module Requirements

Modules use `mkEnableOption` with documentation. Enable features via:
```nix
features = {
  wm.hyprland.enable = true;      # Enables Hyprland compositor
  hardware.bluetooth.enable = true;
  security.doas.enable = true;
  # etc.
};
```

Home-manager modules are enabled in user templates:
```nix
features = {
  cli.nixvim.enable = true;
  desktop.waybar.enable = true;
  applications.browsers.enable = true;
  style.darkmode.enable = true;
};
```

## Key Features
- **Auto-generation**: Hosts declare `_meta`, flake generates all configs
- **Platform templates**: Same user works on NixOS and macOS
- **Home-driven modules**: User features auto-enable system services
- **Standalone packages**: `nix run .#nixvim` works anywhere
