# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Commands

### System Rebuilds
- `sudo nixos-rebuild switch --flake .` - Primary command to rebuild NixOS systems
- `darwin-rebuild switch --flake .` - Primary command to rebuild macOS systems
- `nix flake update && sudo nixos-rebuild switch --flake .` - Update flake inputs and rebuild
- `sudo nix-collect-garbage --delete-old` - Run garbage collection to clean old generations

### Manual Commands
- `nix flake update` - Update all flake inputs
- `nix build .#nixosConfigurations.{hostname}.config.system.build.toplevel` - Build specific host configuration
- `nix build .#darwinConfigurations.{hostname}.config.system.build.toplevel` - Build specific Darwin configuration
- `home-manager switch --flake .#pharo@{hostname}` - Switch home-manager configuration

### Development & Testing
- `nix flake check` - **CRITICAL**: Validate flake syntax and configuration before commits
  - Always run this after making changes to ensure no syntax errors
  - Git-tracked files only - commit changes before running flake check
  - Catches configuration errors early in development process

### Portable Packages
- `nix run .#nixvim` - Run portable nixvim from any system with Nix installed
- `nix run .#tmux-sessionizer` - Run tmux session manager utility

## Architecture Overview (V3)

This is an advanced NixOS/nix-darwin configuration featuring metadata-driven auto-generation, platform-specific user templates, and cross-platform compatibility. The repository manages configurations for:
- **Linux hosts**: `casper` (main desktop), `melchior` (secondary)
- **macOS host**: `alpha-1-5` 
- **Home Manager**: User-specific configurations with consolidated templates

### Key Directory Structure

- **`flake.nix`**: Auto-discovering flake with metadata-driven configuration generation
- **`hosts/`**: Host-specific system configurations with metadata
  - `hosts/{hostname}/default.nix`: Host config with `_meta` (system, architecture, users)
  - `hosts/{hostname}/users/{user}.nix`: Host-specific user overrides (monitors, etc.)
- **`modules/`**: Modular feature system
  - `modules/common/`: Shared platform configuration (Linux/Darwin)
  - `modules/nixos/`: NixOS-specific system modules (hardware, security, wm, apps)
  - `modules/darwin/`: macOS-specific system modules (homebrew)
  - `modules/home-manager/`: Cross-platform user modules (cli, desktop, applications, style)
- **`users/templates/`**: Consolidated user configuration templates
  - `users/templates/{user}/default.nix`: Home-manager features and configuration
  - `users/templates/{user}/home.nix`: Platform-specific settings (username, homeDirectory, etc.)
  - `users/templates/{user}/nixos.nix`: NixOS system user account definition
  - `users/templates/{user}/darwin.nix`: macOS system user account definition
- **`users/common/`**: Shared user configuration (identity, defaults, paths)
- **`pkgs/`**: Custom package definitions and portable applications
  - `pkgs/nixvim/`: Standalone nixvim configuration with modular structure
  - `pkgs/tmux-sessionizer/`: Tmux session manager utility
- **`overlays/`**: Nixpkgs overlays for package modifications
- **`libs/`**: Extended lib functions for metadata handling and home-manager integration

### Modular Feature System

The configuration uses a modular approach with clean separation between system and user features:

**System Features** (`modules/nixos/`, `modules/darwin/`):
- `hardware/`: Hardware-specific modules (bluetooth, printing, graphics, etc.)
- `wm/`: Window manager and desktop environment (Hyprland, fonts, sound)
- `security/`: Security configurations (firewall, doas, polkit, sops)
- `apps/`: System-level applications (Steam, VPN, etc.)
- `homebrew/`: macOS-specific package management (Darwin only)

**User Features** (`modules/home-manager/`):
- `cli/`: Command-line tools and configurations (zsh, tmux, git, portable nixvim)
- `desktop/`: Desktop environment configs (Hyprland, waybar, fuzzel)
- `applications/`: User applications (browsers, media, productivity)
- `style/`: Theming and visual configurations
- `xdg/`: XDG directory and MIME type configurations

**Platform-Specific User Templates** (`users/templates/{user}/`):
- Complete user configurations with platform-specific system accounts
- `{user}/nixos.nix` for NixOS system user configuration
- `{user}/darwin.nix` for macOS system user configuration  
- `{user}/default.nix` for cross-platform home-manager features
- `{user}/home.nix` for platform-specific home-manager settings
- Host-specific overrides only in `hosts/{hostname}/users/{user}.nix` configs

### V3 Key Changes

**Platform-Specific User Templates**:
- Users now have separate `nixos.nix` and `darwin.nix` system configurations
- Platform-specific templates auto-imported based on host `_meta.system`
- Eliminates platform conflicts and enables true cross-platform compatibility

**Reorganized User Configuration**:
- Moved `home/common` → `users/common` for logical organization
- All user-related configuration consolidated under `users/` directory
- Cleaner separation between system modules and user configuration

**Enhanced Auto-Discovery**:
- Template entrypoints (`users/templates/nixos.nix`, `users/templates/darwin.nix`)
- Auto-discovery of platform-specific user system configurations
- Metadata-driven imports: `modules/common/${_meta.system}`

### Build Process

The V3 architecture uses direct system rebuilds:
1. **NixOS**: `sudo nixos-rebuild switch --flake .` 
2. **macOS**: `darwin-rebuild switch --flake .`
3. **Home Manager**: `home-manager switch --flake .#user@hostname`
4. **Validation**: Always run `nix flake check` before rebuilding

### Centralized Configuration System

The configuration uses a centralized approach with three main components:

**User Identity** (`users/common/user-identity.nix`):
- `custom.user.name` - Full name for git, applications
- `custom.user.email` - Email for git, applications  
- `custom.user.username` - System username (auto-derived from home.username)
- `custom.user.homeDirectory` - Home directory path (auto-derived)

**Application Defaults** (`users/common/application-defaults.nix`):
- `custom.defaults.terminal` - Default terminal (kitty)
- `custom.defaults.browser` - Default browser (librewolf)
- `custom.defaults.editor` - Default editor (nvim)
- `custom.defaults.fileManager` - Default file manager (ranger)
- `custom.defaults.copyCommand` - Clipboard utility (wl-copy)
- `custom.defaults.mailClient` - Mail client (defaults to browser for webmail)

**Path Configuration** (`users/common/path-config.nix`):
- `custom.paths.projects` - Projects directory
- `custom.paths.nixcfg` - Nix config repository path
- `custom.paths.remote` - Remote/mounted filesystems directory

### Metadata-Driven Auto-Generation System

**Philosophy**: Hosts declare metadata that drives automatic flake configuration generation, eliminating manual configuration duplication and ensuring consistency.

**Host Metadata Structure** (`hosts/{hostname}/default.nix`):
```nix
{
  # Metadata for flake auto-generation (excluded from actual config)
  _meta = {
    system = "nixos";           # "nixos" or "darwin"
    architecture = "x86_64-linux"; # Target architecture
    users = [ "pharo" ];        # List of users for this host
  };
  
  # Regular host configuration follows...
  imports = [ ../../modules/common/linux /* ... */ ];
  features = { /* host-specific feature toggles */ };
}
```

**Auto-Discovery Process**:
1. **Host Discovery**: Scans `hosts/` directory for subdirectories
2. **Metadata Extraction**: Imports each host's `default.nix` and reads `_meta` attributes
3. **Configuration Generation**: Auto-generates `nixosConfigurations`, `darwinConfigurations`, and `homeConfigurations`
4. **Validation**: Ensures consistency between metadata and actual configuration files

**Validation System**:
- **Missing Configs**: Error if user declared in `_meta.users` but no config file exists in `hosts/{hostname}/users/`
- **Orphaned Configs**: Error if user config file exists but not declared in `_meta.users`
- **Early Detection**: Validation runs during flake evaluation with clear error messages

**Benefits**:
- **DRY Principle**: No manual configuration duplication in flake.nix
- **Consistency**: Metadata validation prevents configuration drift
- **Scalability**: Adding new hosts or users requires minimal changes
- **Maintainability**: Single source of truth for what exists on each host

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

### Consolidated User Template System

**Philosophy**: User configurations are consolidated into complete templates containing home-manager config, platform settings, and system accounts, with host-specific overrides for customization.

**Implementation**:
- **Consolidated Templates** (`users/templates/{user}/`): Complete user configurations with home-manager features, platform settings, and system account definitions
- **Host Overrides** (`hosts/{hostname}/users/{user}.nix`): Only contain host-specific settings (monitors, host-specific tweaks)
- **System Agnostic**: Templates work across NixOS, macOS, and standalone Home Manager
- **Metadata-Driven**: Only users declared in host `_meta.users` get their configurations activated

**V3 Platform-Specific Template Structure**:
```nix
# users/templates/pharo/default.nix (Cross-platform home-manager features)
{ lib, config, ... }: {
  imports = [
    ./home.nix  # Platform-specific settings
    ../../../modules/home-manager/cli
    ../../../modules/home-manager/desktop
    ../../../modules/home-manager/applications
  ];

  features = {
    cli.nixvim.enable = lib.mkDefault true;
    desktop.hyprland.enable = lib.mkDefault true;
    applications.browsers.enable = lib.mkDefault true;
  };
}

# users/templates/pharo/home.nix (Platform-specific home-manager settings)
{ config, lib, ... }: {
  home.username = lib.mkDefault "pharo";
  home.homeDirectory = lib.mkDefault "/home/${config.home.username}";
  home.stateVersion = "24.11";
  
  custom.user = {
    name = lib.mkOverride 500 "Cole Glotfelty";
    email = lib.mkOverride 500 "git@postagepaid.cc";
  };
}

# users/templates/pharo/nixos.nix (NixOS system user account)
{ config, lib, pkgs, inputs, ... }: 
let
  hostName = config.networking.hostName;
  userConfigPath = ../../../hosts/${hostName}/users/pharo.nix;
  userConfigExists = builtins.pathExists userConfigPath;
in mkIf userConfigExists {
  users.users.pharo = {
    isNormalUser = true;
    description = "Cole Glotfelty";
    extraGroups = [ "networkmanager" "wheel" "video" "audio" /* ... */ ];
  };
  
  home-manager.users.pharo = import userConfigPath;
}

# users/templates/coleglotfelty/darwin.nix (macOS system user account)
{ config, lib, pkgs, inputs, ... }: 
let
  hostName = config.networking.hostName;
  userConfigPath = ../../../hosts/${hostName}/users/coleglotfelty.nix;
  userConfigExists = builtins.pathExists userConfigPath;
  isDarwin = pkgs.stdenv.isDarwin;
in mkIf (userConfigExists && isDarwin) {
  users.users.coleglotfelty = {
    name = "coleglotfelty";
    description = "Cole Glotfelty";
    home = "/Users/coleglotfelty";
  };

  system.primaryUser = "coleglotfelty";
  home-manager.users.coleglotfelty = import userConfigPath;
}
```

**Host Override Example**:
```nix
# hosts/casper/users/pharo.nix
{ ... }: {
  imports = [
    ../../../users/common
    ../../../users/templates/pharo  # Imports default.nix automatically
  ];

  custom.hostname = "casper";
  
  # Only host-specific overrides
  features.desktop.hyprland.monitors = [
    "HDMI-A-1,1920x1080@75,auto,auto"
    "HDMI-A-2,1920x1080@75,auto,auto"
  ];
}
```

**Benefits**:
- **Complete Consolidation**: All user-related configuration in one location per user
- **Portability**: Same user config works across NixOS, macOS, and standalone Home Manager
- **DRY Principle**: No duplication between hosts or between home/system configs
- **Easy Maintenance**: Update template to change all hosts simultaneously
- **Flexible Overrides**: Host-specific changes are isolated and clear
- **Metadata Validation**: Prevents configuration drift between declared and actual users
- **Single Source of Truth**: Host metadata drives what users exist on each system

### Home-Driven Host Module Pattern

**Philosophy**: Home Manager configuration is the single source of truth for user features, automatically enabling required host-level system components.

**Implementation**: Uses extended lib functions to detect home-manager user configurations and reactively enable host modules.

**Extended Lib Functions** (`libs/extensions.nix`):
- `lib.mkIfAnyHMOpt config predicate` - Enable host config if ANY home user matches predicate
- `lib.mkIfAllHMOpt config predicate` - Enable host config if ALL home users match predicate  
- `lib.checkHMOpt config testFunc predicate` - Core function to check home users with custom test function

**Current Implementations**:
- **Hyprland**: `modules/nixos/wm/hyprland.nix` auto-enables when any user has `features.desktop.hyprland.enable = true`

**Self-Contained Modules** (no host coordination needed):
- **DevEnv**: Fully contained in `modules/home-manager/cli/devenv.nix` with cross-platform cache configuration
- **NixVim**: Portable standalone configuration in `pkgs/nixvim/` consumed by home-manager integration

**Usage Pattern**:
```nix
# Home-driven modules (auto-enable host components)
features.desktop.hyprland.enable = true;  # Auto-enables host Hyprland system components

# Self-contained modules (no host coordination)  
features.cli.devenv.enable = true;        # Includes cache config, works everywhere
features.cli.nixvim.enable = true;        # Portable nixvim, also runnable via `nix run .#nixvim`

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

### Standalone-First Architecture Pattern

**Philosophy**: Build portable applications that work independently but can be consumed by home-manager for seamless integration.

**Implementation** (`pkgs/nixvim/` as reference):
- **Standalone Config**: Primary configuration in `pkgs/{app}/config.nix` with modular imports
- **Package Builder**: `pkgs/{app}/default.nix` creates runnable package with `makeNixvimWithModule`
- **Config Exposure**: Uses `passthru.config` to expose configuration for home-manager consumption
- **Home Integration**: Home module consumes standalone config: `programs.nixvim = outputs.packages.${pkgs.stdenv.hostPlatform.system}.nixvim.passthru.config // { enable = true; }`

**Benefits**:
- **Portability**: Run anywhere with `nix run .#{package}` without system configuration
- **Modularity**: Maintains modular structure across standalone and home-manager versions
- **Single Source**: Standalone config is primary, eliminating duplication between versions
- **Cross-Platform**: Works on any system with Nix (NixOS, macOS, other Linux distros)

**Usage**:
```nix
# Standalone usage (any system with Nix)
nix run .#nixvim

# Home Manager integration (same config, seamless experience)  
features.cli.nixvim.enable = true;
```

**Creating New Standalone-First Packages**:
1. Create modular config in `pkgs/{app}/` with `config.nix` importing modules
2. Build package in `pkgs/{app}/default.nix` using appropriate builder
3. Expose config via `passthru.config` for home-manager consumption
4. Create home module that consumes exposed config with additional home-specific settings
5. Add package to `pkgs/default.nix` and test both standalone and home-manager integration

### Development Notes

- Uses `nixos-unstable` channel with some stable packages via overlay
- ZSH is the default shell system-wide
- Hyprland window manager with Wayland compositor
- NixVim for Neovim configuration as a flake input (standalone-first architecture with home-manager integration)
- Custom packages in `pkgs/` directory (e.g., tmux-sessionizer)
- All modules are drop-in compatible and reusable by other users
- Configuration follows Nix best practices with proper priority system