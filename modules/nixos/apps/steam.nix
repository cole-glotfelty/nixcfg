{ config, lib, pkgs, ... }:

# NOTE: This could be useful: https://github.com/fufexan/nix-gaming

with lib;
let cfg = config.features.apps.steam;
in {
  options.features.apps.steam = {
    enable = mkEnableOption (lib.mdDoc ''
      Steam gaming platform with optimized performance configurations.
      
      Features:
      - Steam client with Proton compatibility layer for Windows games
      - GameScope session for dedicated gaming mode
      - GameMode for automatic performance optimizations
      - Xbox controller support via xone driver
      - ProtonUp for managing Proton compatibility tools
      
      Use case: Linux gaming and Windows game compatibility
      Dependencies: Graphics drivers (NVIDIA/Intel/AMD), audio system
      Note: Linux only - Steam on macOS uses native Mac version
    '');
  };

  config = mkIf cfg.enable {
    # XBox Controller support
    hardware.xone.enable = true;

    # Enable steam and ability to boot into steam directly
    programs.steam = {
      enable = true;
      gamescopeSession.enable = true;
    };

    # Compositor for better gaming also need to prefix
    programs.gamescope = {
      enable = true;
      capSysNice = true;
    };

    # Will have to prefix executable with gamemoderun
    programs.gamemode.enable = true;

    environment.systemPackages = with pkgs; [ protonup-ng ];
    
    # Create a script that sets the correct path based on the current user
    environment.sessionVariables = {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = mkDefault "$HOME/.steam/root/compatibilitytools.d";
    };
  };
}
