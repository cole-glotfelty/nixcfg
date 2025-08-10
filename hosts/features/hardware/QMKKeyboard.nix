{ config, lib, ... }:

with lib;
let cfg = config.features.hardware.QMKKeyboard;
in {
  options.features.hardware.QMKKeyboard = {
    enable = mkEnableOption (lib.mdDoc ''
      QMK keyboard support for custom mechanical keyboards.
      
      Features:
      - QMK firmware support for programmable keyboards
      - VIA compatibility for real-time keyboard configuration
      - User access to keyboard devices without root privileges
      - Support for custom layouts and macros
      
      Use case: Custom mechanical keyboards with QMK firmware
      Dependencies: QMK-compatible keyboard hardware
      Works with: VIA, QMK Toolbox, custom keyboard firmware
    '');
  };

  config = mkIf cfg.enable {
    hardware.keyboard.qmk.enable = true;
  };
}
