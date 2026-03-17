{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.homebrew;
in {
  options.features.homebrew.enable = mkEnableOption (lib.mdDoc ''
    Homebrew package manager integration for macOS.

    Features:
    - Auto-update on nix-darwin activation
    - Zap cleanup removes unmanaged packages
    - Declarative brew package management

    Note: For GUI apps, enable features.homebrew.casks
  '');

  config = mkIf cfg.enable {
    homebrew = {
      enable = true;
      onActivation = {
        autoUpdate = true; # Auto-update brew packages on activation
        cleanup = "zap"; # Remove all unmanaged homebrew packages
      };
      brews = [ ];
    };
  };
}
