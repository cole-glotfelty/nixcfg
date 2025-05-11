{ config, lib, ... }:

with lib;
let cfg = config.features.desktop.fuzzel;
in {
  options.features.desktop.fuzzel.enable =
    mkEnableOption "enable fuzzel";

  config = mkIf cfg.enable {
    programs.fuzzel = { enable = true; };
  };
}
