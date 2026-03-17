# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Commands

### System Rebuilds
- `sudo nixos-rebuild switch --flake .` - Rebuild NixOS systems
- `darwin-rebuild switch --flake .` - Rebuild macOS systems
- `nix flake update && sudo nixos-rebuild switch --flake .` - Update flake inputs and rebuild
- `sudo nix-collect-garbage --delete-old` - Clean old generations

### Development & Testing
- `nix flake check` - **CRITICAL**: Validate flake syntax before commits
  - Always run after changes to catch configuration errors early
  - Only checks git-tracked files

### Manual Commands
- `nix flake update` - Update all flake inputs
- `nix build .#nixosConfigurations.{hostname}.config.system.build.toplevel` - Build specific host
- `home-manager switch --flake .#pharo@{hostname}` - Switch home-manager standalone

### Portable Packages
- `nix run .#nixvim` - Run portable nixvim from any Nix system
- `nix run .#tmux-sessionizer` - Run tmux session manager

## Architecture Overview

This is an advanced NixOS/nix-darwin configuration featuring metadata-driven auto-generation, platform-specific user templates, and cross-platform compatibility.

### Hosts
- **casper** - NixOS x86_64-linux (main desktop)
- **melchior** - NixOS x86_64-linux (secondary)
- **alpha-1-5** - Darwin aarch64-darwin (macOS)

### Directory Structure

```
nixcfg/
├── flake.nix           # Auto-discovering flake with metadata-driven generation
├── hosts/              # Host-specific configurations
│   └── {hostname}/
│       ├── default.nix         # Host config with _meta
│       ├── configuration.nix   # Hardware/system config
│       └── users/{user}.nix    # Host-specific user overrides
├── modules/
│   ├── common/         # Shared platform config (nixos/, darwin/)
│   ├── nixos/          # NixOS system modules
│   │   ├── hardware/   # bluetooth, nvidia, intel, printing, etc.
│   │   ├── wm/         # hyprland, fonts, fcitx5, sound, wayland
│   │   ├── security/   # doas, polkit, sops, blocklist
│   │   └── apps/       # steam, mullvad-vpn, nixd
│   ├── darwin/         # macOS modules
│   │   └── homebrew/   # homebrew, homebrew-casks
│   └── home-manager/   # User modules (cross-platform)
│       ├── cli/        # zsh, tmux, git, nixvim, devenv, fzf, ranger
│       ├── desktop/    # hyprland, waybar, fuzzel, notifications
│       ├── applications/ # browsers, media, productivity, messaging, discord
│       ├── style/      # darkmode (GTK/Qt theming)
│       └── xdg/        # xdg_dirs, mimeApps
├── users/
│   ├── common/         # Shared user config
│   │   ├── user-identity.nix       # custom.user options
│   │   ├── application-defaults.nix # custom.defaults options
│   │   └── path-config.nix         # custom.paths options
│   └── templates/      # User templates
│       └── {user}/
│           ├── default.nix  # Cross-platform home-manager features
│           ├── home.nix     # Platform-specific HM settings
│           ├── nixos.nix    # NixOS system user account
│           └── darwin.nix   # macOS system user account
├── pkgs/               # Custom packages
│   ├── nixvim/         # Standalone nixvim with modular plugins
│   ├── tmux-sessionizer/
│   └── apple-color-emoji/
├── libs/               # Extended lib functions
│   └── extensions.nix  # mkIfAnyHMOpt, mkIfAllHMOpt, etc.
├── overlays/           # Nixpkgs overlays
│   └── default.nix     # additions, modifications, unstable-packages
└── secrets.yaml        # SOPS-encrypted secrets
```

## Metadata-Driven Auto-Generation

Hosts declare `_meta` that drives automatic flake configuration generation:

```nix
# hosts/{hostname}/default.nix
{
  _meta = {
    system = "nixos";           # "nixos" or "darwin"
    architecture = "x86_64-linux";
    users = [ "pharo" ];
  };

  imports = [ /* ... */ ];
  features = { /* feature toggles */ };
}
```

The flake auto-discovers hosts, extracts metadata, generates configurations, and validates that declared users have matching config files.

## Centralized User Configuration

**User Identity** (`users/common/user-identity.nix`):
- `custom.user.name` - Full name for git, applications
- `custom.user.email` - Email for git, applications
- `custom.user.username` - System username (auto-derived)
- `custom.user.homeDirectory` - Home directory (auto-derived)

**Application Defaults** (`users/common/application-defaults.nix`):
- `custom.defaults.terminal` - Default terminal (kitty)
- `custom.defaults.browser` - Default browser (librewolf)
- `custom.defaults.editor` - Default editor (nvim)
- `custom.defaults.fileManager` - Default file manager (ranger)
- `custom.defaults.copyCommand` - Clipboard utility (wl-copy)
- `custom.defaults.mailClient` - Mail client

**Path Configuration** (`users/common/path-config.nix`):
- `custom.paths.projects` - Projects directory
- `custom.paths.nixcfg` - Nix config repository path
- `custom.paths.remote` - Remote/mounted filesystems

## Key Patterns

### mkDefault Pattern
All module defaults use `mkDefault` for easy overriding:
```nix
programs.zsh.history.size = mkDefault 250000;
```

Override priority: host-specific > user-specific > module defaults

### Home-Driven Host Modules
Home-manager config drives system-level features via lib extensions:
```nix
# Host module auto-enables when any user has the feature
config = lib.mkIfAnyHMOpt config (hmCfg: hmCfg.features.desktop.hyprland.enable or false) {
  programs.hyprland.enable = true;
};
```

### Standalone-First Packages
Packages work independently and integrate with home-manager:
```nix
# Standalone: nix run .#nixvim
# Home-manager: features.cli.nixvim.enable = true;
programs.nixvim = outputs.packages.${system}.nixvim.passthru.config // { enable = true; };
```

### Platform-Specific User Templates
Users have separate system configs per platform:
- `{user}/nixos.nix` - NixOS system user account
- `{user}/darwin.nix` - macOS system user account
- `{user}/default.nix` - Cross-platform home-manager features
- `{user}/home.nix` - Platform-specific home-manager settings

## Module Documentation

All modules include comprehensive documentation in their `mkEnableOption`:
```nix
options.features.wm.fonts.enable = mkEnableOption (lib.mdDoc ''
  System font configuration with comprehensive Unicode and emoji support.

  Features:
  - FiraCode Nerd Font with programming ligatures
  - Complete CJK font coverage with Apple font substitutions
  - Optimized font rendering

  Dependencies: GUI applications
'');
```

## Flake Inputs

| Input | Description |
|-------|-------------|
| nixpkgs | NixOS 25.11 (stable) |
| nixpkgs-unstable | nixos-unstable (via overlay) |
| home-manager | release-25.11 |
| nix-darwin | macOS system management |
| hyprland | Wayland compositor |
| nixvim | Neovim configuration framework |
| sops-nix | Secrets management |
| zen-browser | Firefox-based browser |
| blocklist-hosts | Domain blocklist |
| fcitx5-ori-theme | Input method theme |

## Development Notes

- Uses `nixos-25.11` (stable) with unstable packages available via `pkgs.unstable`
- ZSH is the default shell system-wide
- Hyprland window manager with Wayland compositor
- All modules are user-agnostic and reusable
- Configuration follows Nix best practices with proper priority system
- Fontconfig includes Apple CJK font substitutions (PingFang → Noto Sans CJK)
