{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.features.applications.firefox;
in {
  options.features.applications.firefox = {
    enable = mkEnableOption (lib.mdDoc ''
      Mozilla Firefox browser with performance optimizations.

      Configuration:
      - DuckDuckGo as default search engine
      - Hardware acceleration enabled (WebRender, VAAPI)
      - Wayland support on Linux
      - Font rendering optimizations
      - Privacy-respecting defaults

      Dependencies: pkgs.firefox
    '');
  };

  config = mkIf cfg.enable {
    programs.firefox = {
      enable = true;

      profiles.default = mkDefault {
        id = 0;
        name = "default";
        isDefault = true;

        search = {
          default = "ddg";
          privateDefault = "ddg";
          force = true;
        };

        settings = {
          # Search Engine
          "browser.search.defaultenginename" = "ddg";
          "browser.urlbar.placeholderName" = "ddg";

          # Font Settings
          "gfx.font_rendering.opentype_svg.enabled" = true;
          "layout.css.font-visibility.level" = 1;

          # Hardware Acceleration
          "gfx.webrender.all" = true;
          "media.ffmpeg.vaapi.enabled" = true;

          # Performance
          "browser.cache.disk.enable" = true;
          "browser.cache.memory.enable" = true;

          # Privacy
          "privacy.trackingprotection.enabled" = true;
          "privacy.trackingprotection.socialtracking.enabled" = true;
        };
      };
    };
  };
}
