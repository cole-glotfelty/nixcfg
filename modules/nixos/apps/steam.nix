{
  config,
  lib,
  pkgs,
  ...
}:

# NOTE: This could be useful: https://github.com/fufexan/nix-gaming

with lib;
let
  cfg = config.features.apps.steam;

  # Steam Linux Runtime resets PATH inside its container, hiding the host's mono.
  # Use as a launch option: `ksp-burst-path %command%`
  ksp-burst-path = pkgs.writeShellScriptBin "ksp-burst-path" ''
    args=()
    for a in "$@"; do
      case "$a" in
        */KSP.x86_64) args+=(/usr/bin/env PATH=/usr/bin:/bin:/run/host/usr/bin "$a") ;;
        *) args+=("$a") ;;
      esac
    done
    exec "''${args[@]}"
  '';
in
{
  options.features.apps.steam = {
    enable = mkEnableOption (
      lib.mdDoc ''
        Steam gaming platform with optimized performance configurations.

        Features:
        - Steam client with Proton compatibility layer for Windows games
        - GameScope session for dedicated gaming mode
        - GameMode for automatic performance optimizations
        - Xbox controller support via xone driver
        - ProtonUp for managing Proton compatibility tools
        - ksp-burst-path: KSP launch wrapper exposing mono for KSPBurst

        Use case: Linux gaming and Windows game compatibility
        Dependencies: Graphics drivers (NVIDIA/Intel/AMD), audio system
        Note: Linux only - Steam on macOS uses native Mac version
      ''
    );
  };

  config = mkIf cfg.enable {
    # XBox Controller support
    hardware.xone.enable = true;

    # Enable steam and ability to boot into steam directly
    programs.steam = {
      enable = true;
      gamescopeSession.enable = true;
      package = pkgs.steam.override {
        extraEnv = {
          GAMEMODERUN = "1";
        };
        extraPkgs =
          pkgs: with pkgs; [
            mono
            ksp-burst-path
          ];
      };
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
