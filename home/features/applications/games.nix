{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.applications.games;
in {
  options.features.applications.games.enable =
    mkEnableOption "enable games applications";
  config = mkIf cfg.enable { home.packages = with pkgs; [ lutris bottles ]; };
}
