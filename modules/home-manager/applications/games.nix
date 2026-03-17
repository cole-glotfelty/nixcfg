{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.applications.games;
in {
  options.features.applications.games.enable = mkEnableOption (lib.mdDoc ''
    Gaming utilities for Wine/Proton game management.

    Included apps:
    - Lutris: Game launcher for Wine/emulators
    - Bottles: Wine prefix manager

    Note: For Steam, use features.apps.steam (system-level)
  '');
  config = mkIf cfg.enable { home.packages = with pkgs; [ lutris bottles ]; };
}
