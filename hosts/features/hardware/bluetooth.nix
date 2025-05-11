{ config, lib, ... }:

with lib;
let cfg = config.features.hardware.bluetooth;
in {
  options.features.hardware.bluetooth.enable = mkEnableOption "enable bluetooth";

  config = mkIf cfg.enable {
    hardware.bluetooth.enable = true;
    services.blueman.enable = true;

  };
}
