{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.homebrew;
in {
  options.features.homebrew.enable = mkEnableOption "enable homebrew";

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
