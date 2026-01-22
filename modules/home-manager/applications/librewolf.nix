{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.features.applications.librewolf;
in {
  options.features.applications.librewolf = {
    enable = mkEnableOption (lib.mdDoc ''
      LibreWolf browser - privacy-focused Firefox fork.

      Configuration:
      - DuckDuckGo as default search engine
      - Anti-fingerprinting disabled for better dark mode support
      - Hardware acceleration enabled (WebRender, VAAPI)
      - Wayland support enabled
      - Font rendering optimizations
      - Auto-install extensions enabled

      Dependencies: pkgs.librewolf-wayland (from stable)
    '');
  };

  config = mkIf cfg.enable {
    programs.librewolf = {
      enable = true;
      package = mkDefault pkgs.stable.librewolf-wayland;

      settings = mkDefault {
        # Search Engine
        "browser.search.defaultenginename" = "DuckDuckGo";
        "browser.urlbar.placeholderName" = "DuckDuckGo";
        "browser.search.selectedEngine" = "DuckDuckGo";

        # Font Settings
        "gfx.font_rendering.opentype_svg.enabled" = true;
        "layout.css.font-visibility.level" = 1; # Improve web font rendering

        # Fingerprinting resist was blocking suggested dark mode
        "privacy.resistFingerprinting" = false;
        "privacy.resistFingerprinting.letterboxing" = false;

        # Auto Install Extensions
        "extensions.autoDisableScopes" = 0;

        # Hardware Acceleration
        "gfx.webrender.all" = true;
        "media.ffmpeg.vaapi.enabled" = true;
      };
    };
  };
}
