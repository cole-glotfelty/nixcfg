{ config, lib, pkgs, ... }:

# NOTE: This could be useful: https://github.com/fufexan/nix-gaming

with lib;
let cfg = config.features.apps.steam;
in {
  options.features.apps.steam.enable = mkEnableOption "enable steam";

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

    environment.systemPackages = with pkgs; [ protonup ];
    environment.sessionVariables = {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS =
        "/home/pharo/.steam/root/compatibilitytools.d";
    };
  };
}
