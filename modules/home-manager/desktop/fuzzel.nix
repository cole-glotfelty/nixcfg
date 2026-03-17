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
    programs.fuzzel = let
      colors = config.features.style.colors.palette.dark;
    in {
      enable = true;
      settings = mkDefault {
        main = {
          font = "FiraCode Nerd Font Mono:size=12";
          terminal = config.custom.defaults.terminal;
        };
        colors = {
          background = "${colors.bg}ee";
          text = "${colors.fg}ff";
          match = "${colors.blue}ff";
          selection = "${colors.selection}ff";
          selection-text = "${colors.fg}ff";
          selection-match = "${colors.cyan}ff";
          border = "${colors.blue}ff";
        };
        border = {
          width = 2;
          radius = 10;
        };
      };
    };
  };
}
