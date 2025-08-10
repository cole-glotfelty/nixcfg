{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.desktop.notifications;
in {
  options.features.desktop.notifications = {
    enable = mkEnableOption (lib.mdDoc ''
      Desktop notifications via Dunst notification daemon.
      
      Features:
      - Lightweight notification daemon for Wayland/X11
      - Customizable notification appearance and behavior
      - Support for notification actions and history
      - Integration with libnotify for application notifications
      
      Includes: dunst service, libnotify utilities
      Used by: Applications sending desktop notifications, system events
    '');
  };

  config = mkIf cfg.enable {
    # TODO: Is this necissary?
    home.packages = with pkgs; [ libnotify ];
    services.dunst = { enable = true; };
  };
}
