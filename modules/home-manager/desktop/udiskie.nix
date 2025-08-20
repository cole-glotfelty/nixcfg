{ config, lib, ... }:

with lib;
let cfg = config.features.desktop.udiskie;
in {
  options.features.desktop.udiskie = {
    enable = mkEnableOption (lib.mdDoc ''
      Udiskie automatic USB and removable device mounting.
      
      Features:
      - Automatic mounting of USB drives, SD cards, and other removable media
      - Background service for seamless device handling
      - Desktop integration for mount/unmount notifications
      - User-space mounting without root privileges
      
      Useful for: Laptop and desktop systems with removable storage
      Service: Runs as background systemd user service
    '');
  };

  config = mkIf cfg.enable {
    services.udiskie.enable = true;
  };
}
