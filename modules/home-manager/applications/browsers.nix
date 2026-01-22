{ config, lib, ... }:

with lib;
let
  defaultBrowser = config.custom.defaults.browser;
in {
  # Browser coordinator module - manages browser environment configuration.
  #
  # This module (always enabled):
  # - Sets the BROWSER environment variable from custom.defaults.browser
  # - Automatically enables the preferred browser module based on custom.defaults.browser
  # - Provides a central coordination point for browser features
  #
  # Individual browser modules available:
  # - features.applications.librewolf.enable - Privacy-focused Firefox fork
  # - features.applications.firefox.enable - Mozilla Firefox
  # - features.applications.brave.enable - Privacy-focused Chromium
  # - features.applications.zen-browser.enable - Modern Firefox-based browser
  #
  # Dependencies: custom.defaults.browser

  # Set browser environment variable
  home.sessionVariables = {
    BROWSER = defaultBrowser;
  };

  # Automatically enable the preferred browser module
  features.applications = {
    librewolf.enable = mkIf (defaultBrowser == "librewolf") (mkDefault true);
    firefox.enable = mkIf (defaultBrowser == "firefox") (mkDefault true);
    brave.enable = mkIf (defaultBrowser == "brave") (mkDefault true);
    zen-browser.enable = mkIf (defaultBrowser == "zen-browser") (mkDefault true);
  };
}
