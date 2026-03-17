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
    programs.kitty = let
      colors = config.features.style.colors.palette.dark;
    in {
      enable = true;
      shellIntegration.mode = mkDefault "no-cursor no-sudo";
      shellIntegration.enableZshIntegration = mkDefault true;
      shellIntegration.enableBashIntegration = mkDefault true;

      font = {
        package = mkDefault pkgs.nerd-fonts.fira-code;
        name = mkDefault "FiraCode Nerd Font Mono";
      };

      extraConfig = mkDefault ''
        # Map CJK unicode ranges to a monospace CJK font
        symbol_map U+3000-U+9FFF,U+AC00-U+D7AF,U+F900-U+FAFF,U+FF00-U+FFEF Noto Sans Mono CJK JP
      '';

      settings = mkDefault {
        cursor_shape = "block";
        cursor_blink_interval = 0;
        scrollback_lines = 10000;
        detect_urls = true;
        background_opacity = "0.3";
        # Tokyo Night Storm colors
        background = "#${colors.bg}";
        foreground = "#${colors.fg}";
        selection_background = "#${colors.selection}";
        selection_foreground = "#${colors.fg}";
        cursor = "#${colors.fg}";
        # Normal colors (0-7)
        color0 = "#${colors.black}";
        color1 = "#${colors.red}";
        color2 = "#${colors.green}";
        color3 = "#${colors.yellow}";
        color4 = "#${colors.blue}";
        color5 = "#${colors.magenta}";
        color6 = "#${colors.cyan}";
        color7 = "#${colors.white}";
        # Bright colors (8-15)
        color8 = "#${colors.brightBlack}";
        color9 = "#${colors.red}";
        color10 = "#${colors.green}";
        color11 = "#${colors.yellow}";
        color12 = "#${colors.blue}";
        color13 = "#${colors.magenta}";
        color14 = "#${colors.cyan}";
        color15 = "#${colors.brightWhite}";
      };
    };
  };
}
