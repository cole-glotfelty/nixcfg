{ config, lib, ... }:

with lib;
let cfg = config.features.desktop.udiskie;
in {
  options.features.desktop.udiskie.enable =
    mkEnableOption "enable udiske USB Device automounting";

  config = mkIf cfg.enable {
    services.udiskie.enable = true;
  };
}
