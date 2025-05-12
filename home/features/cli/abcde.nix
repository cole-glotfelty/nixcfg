{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.cli.abcde;
in {
  options.features.cli.abcde.enable = mkEnableOption "enable abcde CD ripper";

  config = mkIf cfg.enable { home.packages = with pkgs; [ abcde ]; };
}
