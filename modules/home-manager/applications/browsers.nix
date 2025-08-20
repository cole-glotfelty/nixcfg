{ inputs, config, lib, pkgs, ... }:

with lib;
let cfg = config.features.applications.browsers;
in {
  options.features.applications.browsers = {
    enable = mkEnableOption (lib.mdDoc ''
      Web browser applications with privacy and performance optimizations.
      
      Includes:
      - LibreWolf (privacy-focused Firefox) with Wayland support and anti-fingerprinting disabled for better dark mode
      - Ungoogled Chromium for Chromium-based web compatibility
      - Zen Browser (modern Firefox-based browser)
      - Brave Browser available as separate module (features.applications.brave.enable)
      - DuckDuckGo as default search engine across browsers
      - Hardware acceleration enabled (WebRender, VAAPI)
      - Browser environment variable set from custom.defaults.browser
      
      Dependencies: custom.defaults.browser, zen-browser flake input
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

        # fingerprinting resist was what was blocking suggested darkmode
        "privacy.resistFingerprinting" = false;
        "privacy.resistFingerprinting.letterboxing" = false;

        # Auto Install Extensions
        "extensions.autoDisableScopes" = 0;

        # Hardware Acceleration
        "gfx.webrender.all" = true;
        "media.ffmpeg.vaapi.enabled" = true;
      };
    };

    home.sessionVariables = { BROWSER = config.custom.defaults.browser; };

    home.packages = 
      [ inputs.zen-browser.packages.x86_64-linux.default ];
  };
}
