{ config, lib, ... }:

with lib;
let cfg = config.features.desktop.fuzzel;
in {
  options.features.desktop.fuzzel = {
    enable = mkEnableOption (lib.mdDoc ''
      Fuzzel application launcher for Wayland.
      
      Features:
      - Fast, minimalist application launcher
      - Wayland-native with low resource usage
      - Fuzzy search for quick app finding
      - Keyboard-driven interface
      
      Used by: Hyprland (as $menu variable)
      Alternative to: dmenu, rofi on Wayland
    '');
  };

  config = mkIf cfg.enable {
    programs.fuzzel = { enable = true; };
  };
}
