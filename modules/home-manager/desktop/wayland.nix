{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.desktop.wayland;
in {
  options.features.desktop.wayland = {
    enable = mkEnableOption (lib.mdDoc ''
      Essential Wayland tools and utilities for window managers.
      
      Includes:
      - grim + slurp: Screenshot tools (grim for capture, slurp for area selection)
      - wl-clipboard: Wayland clipboard utilities (wl-copy, wl-paste)
      - wlogout: Logout menu for Wayland
      - Qt5/Qt6 Wayland support for GUI applications
      
      Designed for: Hyprland and other Wayland compositors
      Dependencies: Wayland-based desktop environment
    '');
  };

  config = mkIf cfg.enable {
    warnings = optional pkgs.stdenv.isDarwin
      "Wayland tools are enabled but you're on macOS. Wayland is Linux-specific - consider disabling features.desktop.wayland.enable on macOS systems.";

    assertions = [
      {
        assertion = pkgs.stdenv.isLinux;
        message = ''
          Wayland module is only supported on Linux systems.
          
          Current platform: ${pkgs.stdenv.hostPlatform.system}
          
          This module provides Linux-specific Wayland tools:
            • grim, slurp (screenshot tools)
            • wl-clipboard (Wayland clipboard)
            • wlogout (Wayland logout menu)
          
          For other platforms:
            • macOS: Disable this module and use native tools
            • Non-Wayland Linux: Consider X11 alternatives
        '';
      }
    ];

    # NOTE: All commented out packages deserve to be researched at a later date
    home.packages = with pkgs; [
      grim
      slurp
      qt5.qtwayland
      qt6.qtwayland
      # waypipe
      # wf-recorder
      # wl-mirror
      wl-clipboard
      wlogout
      networkmanager_dmenu
      # wtype
      # ydotool
    ];

    xdg.configFile."networkmanager-dmenu/config.ini".text = ''
      [dmenu]
      dmenu_command = fuzzel --dmenu

      [editor]
      terminal = ${config.custom.defaults.terminal}
    '';
  };
}
