{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.wm.wayland;
in {
  options.features.wm.wayland.enable = mkEnableOption "enable wayland system level support";

  config = mkIf cfg.enable {
    # Enable touchpad support (enabled default in most desktopManager).
    services.libinput.enable = true;

    services.gnome = { gnome-keyring.enable = true; };

    # Configure xwayland
    services.xserver = {
      enable = true;
      excludePackages = [ pkgs.xterm ];
      # Configure keymap in X11
      xkb = {
        layout = "us";
        variant = "";
      };
    };
  };
}
