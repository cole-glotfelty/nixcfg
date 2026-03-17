{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.wm.wayland;
in {
  options.features.wm.wayland.enable = mkEnableOption (lib.mdDoc ''
    System-level Wayland support and XWayland configuration.

    Features:
    - Touchpad support via libinput
    - GNOME keyring integration
    - XWayland with US keyboard layout
    - Excludes xterm from X server packages

    Dependencies: Desktop environment or window manager
  '');

  config = mkIf cfg.enable {
    # Enable touchpad support (enabled default in most desktopManager).
    services.libinput.enable = true;

    services.gnome = { gnome-keyring.enable = true; };

    # Configure xwayland
    services.xserver = {
      excludePackages = [ pkgs.xterm ];
      # Configure keymap in X11
      xkb = {
        layout = "us";
        variant = "";
      };
    };
  };
}
