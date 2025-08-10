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
      - DuckDuckGo as default search engine across browsers
      - Hardware acceleration enabled (WebRender, VAAPI)
      - Browser environment variable set from custom.defaults.browser
      
      Dependencies: custom.defaults.browser, zen-browser flake input
    '');
  };
  config = mkIf cfg.enable {
    # TODO: expand on this config, should not have to change anything just sign in
    # TODO: figure out why slides lags and freezes
    # programs.firefox = {
    #   enable = true;
    #   # package = pkgs.librewolf-wayland;
    #   # package = pkgs.librewolf;
    #   package = pkgs.librewolf-bin;
    #   profiles.default = {
    #     # search = {
    #     #   force = true;
    #     #   default = "DuckDuckGo";
    #     #   privateDefault = "DuckDuckGo";
    #     # };
    #     settings = {
    #       # Search Engine
    #       # "browser.search.defaultenginename" = "DuckDuckGo";
    #       # "browser.urlbar.placeholderName" = "DuckDuckGo";
    #       # "browser.search.selectedEngine" = "DuckDuckGo";
    #
    #       # Font Settings
    #       "gfx.font_rendering.opentype_svg.enabled" = true;
    #       "layout.css.font-visibility.level" = 1; # Improve web font rendering
    #
    #       # fingerprinting resist was what was blocking suggested darkmode
    #       "privacy.resistFingerprinting" = false;
    #       "privacy.resistFingerprinting.letterboxing" = false;
    #
    #       # Auto Install Extensions
    #       "extensions.autoDisableScopes" = 0;
    #
    #       # Hardware Acceleration
    #       "gfx.webrender.all" = true;
    #       "media.ffmpeg.vaapi.enabled" = true;
    #
    #       # # Font Settings
    #       # "gfx.font_rendering.opentype_svg.enabled" = true;
    #       # "layout.css.font-visibility.level" = 1; # Improve web font rendering
    #       #
    #       # # Browser UI dark mode settings
    #       # "ui.systemUsesDarkTheme" = 1;
    #       # "browser.theme.content-theme" = 0;
    #       # "browser.theme.toolbar-theme" = 0;
    #       # "browser.in-content.dark-mode" = true;
    #       #
    #       # # Website dark mode via prefers-color-scheme
    #       # "layout.css.prefers-color-scheme.content-override" = 0;
    #       #
    #       # # Additional settings for better dark mode integration
    #       # "widget.content.allow-gtk-dark-theme" = true;
    #       # "browser.display.use_system_colors" = true;
    #       #
    #       # # Make sure LibreWolf's privacy features don't block dark mode
    #       # "privacy.resistFingerprinting.letterboxing" = false;
    #       # "privacy.resistFingerprinting" = false;
    #     };
    #   };
    # };

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

    programs.chromium = {
      # TODO: add extensions here - ublock, bitwarden
      enable = mkDefault true;
      package = mkDefault pkgs.ungoogled-chromium;
    };

    home.sessionVariables = { BROWSER = config.custom.defaults.browser; };

    home.packages = 
      [ inputs.zen-browser.packages.x86_64-linux.default ];
  };
}
