{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.applications.electronTweaks;
in {
  options.features.applications.electronTweaks.enable =
    mkEnableOption "tweaks for electron applications";
  config = mkIf cfg.enable {
    xdg.desktopEntries.discord = {
      name = "Discord";
      exec =
        "discord --enable-features=UseOzonePlatform --ozone-platform=wayland --enable-wayland-ime";
      icon = "discord";
      type = "Application";
      terminal = false;
    };

    # Add configuration for Todoist
    xdg.desktopEntries.todoist = {
      name = "Todoist";
      exec =
        "todoist --enable-features=UseOzonePlatform --ozone-platform=wayland --enable-wayland-ime --force-device-scale-factor=1.0";
      icon = "todoist";
      type = "Application";
      terminal = false;
    };

    # Add this to your home.nix or a relevant config file
    home.sessionVariables = {
      NIXOS_OZONE_WL = "1"; # General fix for Electron apps
    };

  };
}
