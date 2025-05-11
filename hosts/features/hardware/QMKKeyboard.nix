{ config, lib, ... }:

with lib;
let cfg = config.features.hardware.QMKKeyboard;
in {
  options.features.hardware.QMKKeyboard.enable =
    mkEnableOption "enable QMKKeyboard (so VIA can access keyboards)";

  config = mkIf cfg.enable {
    hardware.keyboard.qmk.enable = true;
  };
}
