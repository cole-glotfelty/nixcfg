{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.wm.dbus;
in {
  options.features.wm.dbus.enable = mkEnableOption (lib.mdDoc ''
    D-Bus message bus system with dconf support.

    Features:
    - D-Bus broker implementation for IPC
    - dconf for application settings storage
    - Required for GTK/GNOME application settings

    Dependencies: Desktop environment
  '');

  config = mkIf cfg.enable {
    services.dbus = {
      enable = true;
      implementation = "broker";
      packages = [ pkgs.dconf ];
    };

    programs.dconf = { enable = true; };
  };
}
