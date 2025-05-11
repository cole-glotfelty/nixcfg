{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.security.polkit;
in {
  options.features.security.polkit.enable =
    mkEnableOption "enable polkit";

  config = mkIf cfg.enable {
    # TODO: come back here if there's ever an issue (it's bound to happen)
    security.polkit = {
      enable = true;
      # package = pkgs.hyprpolkitagent;
    };
  };
}
