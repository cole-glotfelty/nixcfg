{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.features.applications.ghostty;
  palette = config.features.style.colors.palette;

  # Light theme wrapper script
  ghosttyLight = pkgs.writeShellScriptBin "ghostty-light" ''
    exec ghostty \
      --background="#${palette.light.bg}" \
      --foreground="#${palette.light.fg}" \
      --selection-background="#${palette.light.selection}" \
      --selection-foreground="#${palette.light.fg}" \
      --cursor-color="#${palette.light.fg}" \
      --palette="0=#${palette.light.black}" \
      --palette="1=#${palette.light.red}" \
      --palette="2=#${palette.light.green}" \
      --palette="3=#${palette.light.yellow}" \
      --palette="4=#${palette.light.blue}" \
      --palette="5=#${palette.light.magenta}" \
      --palette="6=#${palette.light.cyan}" \
      --palette="7=#${palette.light.white}" \
      --palette="8=#${palette.light.brightBlack}" \
      --palette="9=#${palette.light.red}" \
      --palette="10=#${palette.light.green}" \
      --palette="11=#${palette.light.yellow}" \
      --palette="12=#${palette.light.blue}" \
      --palette="13=#${palette.light.magenta}" \
      --palette="14=#${palette.light.cyan}" \
      --palette="15=#${palette.light.brightWhite}" \
      "$@"
  '';
in {
  options.features.applications.ghostty = {
    enable = mkEnableOption (lib.mdDoc ''
      Ghostty terminal emulator with modern GPU acceleration and shell integration.

      Features:
      - Tokyo Night theme for consistent dark mode experience
      - FiraCode Nerd Font with programming ligatures and icons
      - Shell integration for Zsh and Bash (no cursor/sudo modifications)
      - Block cursor with no blinking for focused editing
      - Extended scrollback (10,000 lines) for debugging
      - GPU-accelerated rendering for smooth performance
      - ghostty-light command for light theme variant

      Alternative to Kitty with similar configuration approach.
      Integrates with: Zsh, Bash, custom.defaults.terminal
    '');
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      nerd-fonts.fira-code
      ghosttyLight
    ];

    programs.ghostty = let
      colors = palette.dark;
    in {
      enable = true;
      enableZshIntegration = mkDefault true;
      enableBashIntegration = mkDefault true;

      settings = mkDefault {
        shell-integration-features = "no-cursor, no-sudo";
        cursor-style-blink = false;
        cursor-style = "block";

        font-family = [
          "FiraCode Nerd Font Mono"
          "Noto Sans Mono CJK JP"
          "Noto Sans Mono CJK SC"
          "Noto Sans Mono CJK TC"
          "Noto Sans Mono CJK KR"
        ];
        font-thicken = true;
        font-size = 11;
        font-feature = "+cv01,+cv02,+cv14,+ss04,+ss07,+ss09";

        # Match kitty scrollback configuration
        scrollback-limit = 10000;

        # Match kitty URL detection
        mouse-hide-while-typing = true;
        background-opacity = 0.3;

        # Tokyo Night Storm colors
        background = "#${colors.bg}";
        foreground = "#${colors.fg}";
        selection-background = "#${colors.selection}";
        selection-foreground = "#${colors.fg}";
        cursor-color = "#${colors.fg}";
        palette = [
          # Normal colors (0-7)
          "0=#${colors.black}"
          "1=#${colors.red}"
          "2=#${colors.green}"
          "3=#${colors.yellow}"
          "4=#${colors.blue}"
          "5=#${colors.magenta}"
          "6=#${colors.cyan}"
          "7=#${colors.white}"
          # Bright colors (8-15)
          "8=#${colors.brightBlack}"
          "9=#${colors.red}"
          "10=#${colors.green}"
          "11=#${colors.yellow}"
          "12=#${colors.blue}"
          "13=#${colors.magenta}"
          "14=#${colors.cyan}"
          "15=#${colors.brightWhite}"
        ];
      };
    };
  };
}
