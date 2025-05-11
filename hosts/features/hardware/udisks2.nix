{ config, lib, ... }:

with lib;
let cfg = config.features.hardware.udisks2;
in {
  options.features.hardware.udisks2.enable = mkEnableOption "enable udisks2 for udiskie";

  config = mkIf cfg.enable {
    services.xserver.desktopManager.runXdgAutostartIfNone = mkDefault true;
    services.udisks2.enable = true;
  };
}
