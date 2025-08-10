# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Commands

### System Rebuilds
- `just rebuild` - Primary command to rebuild the system (runs `./scripts/rebuild.sh`)
- `just update` - Update flake inputs and rebuild (`nix flake update` + `just rebuild`)
- `just gc` - Run garbage collection to clean old generations

### Manual Commands
- `sudo nixos-rebuild switch --flake .` - Linux system rebuild
- `darwin-rebuild switch --flake .` - macOS system rebuild  
- `nix flake update` - Update all flake inputs
- `sudo nix-collect-garbage --delete-old` - Clean old generations

### Development & Testing
- `nix flake check` - **CRITICAL**: Validate flake syntax and configuration before commits
  - Always run this after making changes to ensure no syntax errors
  - Git-tracked files only - commit changes before running flake check
  - Catches configuration errors early in development process

## Architecture Overview

This is a comprehensive NixOS/nix-darwin configuration using flakes for multi-system management. The repository manages configurations for:
- **Linux hosts**: `casper` (main desktop), `melchior` (secondary)
- **macOS host**: `alpha-1-5` 
- **Home Manager**: User-specific configurations for `pharo` user

### Key Directory Structure

- **`flake.nix`**: Main flake configuration defining all systems and inputs
- **`hosts/`**: System-level configurations
  - `hosts/common/`: Shared system configuration (Linux/Darwin)
  - `hosts/{hostname}/`: Host-specific configurations
  - `hosts/features/`: Modular system features (hardware, security, wm, apps)
- **`home/`**: Home Manager configurations
  - `home/common/`: Shared user configuration
  - `home/features/`: Modular user features (cli, desktop, applications, style)
  - `home/{platform}/{user}/`: User-specific configurations per platform
- **`pkgs/`**: Custom package definitions
- **`overlays/`**: Nixpkgs overlays for package modifications
- **`lib/`**: Extended lib functions for home-manager integration
- **`scripts/`**: Build and maintenance scripts

### Modular Feature System

The configuration uses a modular approach with feature toggles:

**System Features** (`hosts/features/`):
- `hardware/`: Hardware-specific modules (bluetooth, printing, graphics, etc.)
- `wm/`: Window manager and desktop environment (Hyprland, fonts, sound)
- `security/`: Security configurations (firewall, doas, polkit, sops)
- `apps/`: System-level applications (Steam, VPN, etc.)

**User Features** (`home/features/`):
- `cli/`: Command-line tools and configurations (zsh, tmux, git, nixvim)
- `desktop/`: Desktop environment configs (Hyprland, waybar, fuzzel)
- `applications/`: User applications (browsers, media, productivity)
- `style/`: Theming and visual configurations

### Build Process

The `rebuild.sh` script handles:
1. OS detection (Linux vs macOS)
2. Git diff display of `.nix` changes
3. System rebuild with error handling and logging
4. Automatic git commit with generation metadata (Linux only)

### Centralized Configuration System

The configuration uses a centralized approach with three main components:

**User Identity** (`home/common/user-identity.nix`):
- `custom.user.name` - Full name for git, applications
- `custom.user.email` - Email for git, applications  
- `custom.user.username` - System username (auto-derived from home.username)
- `custom.user.homeDirectory` - Home directory path (auto-derived)

**Application Defaults** (`home/common/application-defaults.nix`):
- `custom.defaults.terminal` - Default terminal (kitty)
- `custom.defaults.browser` - Default browser (librewolf)
- `custom.defaults.editor` - Default editor (nvim)
- `custom.defaults.fileManager` - Default file manager (ranger)
- `custom.defaults.copyCommand` - Clipboard utility (wl-copy)
- `custom.defaults.mailClient` - Mail client (defaults to browser for webmail)

**Path Configuration** (`home/common/path-config.nix`):
- `custom.paths.projects` - Projects directory
- `custom.paths.nixcfg` - Nix config repository path
- `custom.paths.remote` - Remote/mounted filesystems directory

### Configuration Management

- **Centralized Config**: Single source of truth for user preferences and applications
- **mkDefault Pattern**: All module defaults use `mkDefault` for easy overriding
- **Override Priority**: host-specific > user-specific > module defaults
- **User-Agnostic Modules**: All modules work for any user without hardcoded references
- **Secrets**: Managed via `sops-nix` with `secrets.yaml`
- **Feature Toggles**: Each host enables specific features via boolean options
- **Overlays**: Custom package modifications and additions
- **Flake Inputs**: External dependencies (nixpkgs, home-manager, nixvim, etc.)

### Customization Examples

**Override application defaults per host:**
```nix
# In host-specific configuration
custom.defaults.terminal = "ghostty";
custom.defaults.browser = "firefox";
```

**Override module defaults with priority:**
```nix
# Override ZSH history size
programs.zsh.history.size = mkOverride 150 500000;
# Force override (use sparingly)  
programs.zsh.autocd = mkForce false;
```

**Per-host user configuration:**
```nix
custom.user = {
  name = "Work User";
  email = "work@company.com";
};
```

### Home-Driven Host Module Pattern

**Philosophy**: Home Manager configuration is the single source of truth for user features, automatically enabling required host-level system components.

**Implementation**: Uses extended lib functions to detect home-manager user configurations and reactively enable host modules.

**Extended Lib Functions** (`lib/extensions.nix`):
- `lib.mkIfAnyHMOpt config predicate` - Enable host config if ANY home user matches predicate
- `lib.mkIfAllHMOpt config predicate` - Enable host config if ALL home users match predicate  
- `lib.checkHMOpt config testFunc predicate` - Core function to check home users with custom test function

**Current Implementations**:
- **Hyprland**: `hosts/features/wm/hyprland.nix` auto-enables when any user has `features.desktop.hyprland.enable = true`

**Self-Contained Modules** (no host coordination needed):
- **DevEnv**: Fully contained in `home/features/cli/devenv.nix` with cross-platform cache configuration

**Usage Pattern**:
```nix
# Home-driven modules (auto-enable host components)
features.desktop.hyprland.enable = true;  # Auto-enables host Hyprland system components

# Self-contained modules (no host coordination)  
features.cli.devenv.enable = true;        # Includes cache config, works everywhere

# Host module automatically detects and enables (no manual config needed)
config = lib.mkIfAnyHMOpt config (hmCfg: hmCfg.features.desktop.hyprland.enable or false) {
  programs.hyprland.enable = true;
  # ... rest of system configuration
};
```

**Creating New Home-Driven Modules**:
1. Remove `options` section from host module
2. Wrap config in `lib.mkIfAnyHMOpt config (predicate) { ... }`  
3. Add documentation to home module explaining auto-enabled system components
4. Test with `nix flake check`

**When to Use Each Pattern**:
- **Home-Driven**: Features that require both user config AND system services (e.g., Hyprland needs compositor + user config)
- **Self-Contained**: Features that work entirely at user level (e.g., DevEnv with cache optimization)

**Benefits**:
- Single source of truth (home config drives system config)
- Cross-platform compatibility (works on NixOS, nix-darwin, standalone Home Manager) 
- No duplication between host/home configurations
- Automatic system dependency management

### Development Notes

- Uses `nixos-unstable` channel with some stable packages via overlay
- ZSH is the default shell system-wide
- Hyprland window manager with Wayland compositor
- NixVim for Neovim configuration as a flake input
- Custom packages in `pkgs/` directory (e.g., tmux-sessionizer)
- All modules are drop-in compatible and reusable by other users
- Configuration follows Nix best practices with proper priority system