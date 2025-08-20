{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.applications.productivity;
in {
  options.features.applications.productivity.enable =
    mkEnableOption "enable productivity applications";
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      obsidian
    ];
  };
}
