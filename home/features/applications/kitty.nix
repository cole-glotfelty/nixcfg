{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.applications.kitty;
in {
  options.features.applications.kitty = {
    enable = mkEnableOption (lib.mdDoc ''
      Kitty terminal emulator with optimized configuration for development.
      
      Features:
      - Tokyo Night theme for consistent dark mode experience
      - FiraCode Nerd Font with programming ligatures and icons
      - Shell integration for Zsh and Bash (no cursor/sudo modifications)
      - Block cursor with no blinking for focused editing
      - Extended scrollback (10,000 lines) for debugging
      - URL detection and click-to-open
      
      Integrates with: Zsh, Bash, custom.defaults.terminal
    '');
  };
  config = mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      shellIntegration.mode = mkDefault "no-cursor no-sudo";
      shellIntegration.enableZshIntegration = mkDefault true;
      shellIntegration.enableBashIntegration = mkDefault true;
      themeFile = mkDefault "tokyo_night_night";

      font = {
        package = mkDefault pkgs.nerd-fonts.fira-code;
        name = mkDefault "FiraCode Nerd Font Mono";
      };

      settings = mkDefault {
        cursor_shape = "block";
        cursor_blink_interval = 0;
        scrollback_lines = 10000;
        detect_urls = true;
      };
    };
  };
}
