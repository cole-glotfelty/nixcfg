{ config, lib, ... }:

with lib;
let cfg = config.features.hardware.udisks2;
in {
  options.features.hardware.udisks2 = {
    enable = mkEnableOption (lib.mdDoc ''
      UDisks2 service for automatic disk mounting and management.
      
      Features:
      - Automatic mounting of USB drives, SD cards, and external storage
      - User-space disk management without requiring root privileges
      - Integration with desktop environments for storage notifications
      - Support for udiskie and other automount utilities
      
      Use case: Desktop systems that need automatic storage device handling
      Dependencies: Desktop environment or window manager
      Integrates with: udiskie (home-manager), desktop file managers
    '');
  };

  config = mkIf cfg.enable {
    services.xserver.desktopManager.runXdgAutostartIfNone = mkDefault true;
    services.udisks2.enable = true;
  };
}
