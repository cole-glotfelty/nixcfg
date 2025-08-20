{ config, lib, ... }:

with lib;
let cfg = config.features.hardware.bluetooth;
in {
  options.features.hardware.bluetooth = {
    enable = mkEnableOption (lib.mdDoc ''
      Bluetooth support with GUI management interface.
      
      Features:
      - System-wide Bluetooth support for all devices
      - Blueman GUI for pairing and managing Bluetooth devices
      - Audio device support for headphones, speakers, and microphones
      - File transfer capabilities between devices
      
      Use case: Desktop and laptop systems with Bluetooth hardware
      Dependencies: Hardware with Bluetooth capability
    '');
  };

  config = mkIf cfg.enable {
    hardware.bluetooth.enable = mkDefault true;
    services.blueman.enable = mkDefault true;
  };
}
