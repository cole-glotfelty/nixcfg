{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.applications.browsers;
in {
  options.features.applications.browsers.enable =
    mkEnableOption "enable browser applications";
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
      package = pkgs.stable.librewolf-wayland;
      settings = {
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
      enable = true;
      package = pkgs.ungoogled-chromium;
    };

    home.sessionVariables = { BROWSER = "librewolf"; };

    # home.packages = with pkgs; [ ungoogled-chromium ];
  };
}
