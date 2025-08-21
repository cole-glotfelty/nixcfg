{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.applications.ghostty;
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
      
      Alternative to Kitty with similar configuration approach.
      Integrates with: Zsh, Bash, custom.defaults.terminal
    '');
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [ nerd-fonts.fira-code ];

    programs.ghostty = {
      enable = true;
      enableZshIntegration = mkDefault true;
      enableBashIntegration = mkDefault true;

      settings = mkDefault {
        shell-integration-features = "no-cursor, no-sudo";
        cursor-style-blink = false;
        cursor-style = "block";

        font-family = "FiraCode Nerd Font Mono";
        font-thicken = true;
        font-size = 11;
        font-feature = "+cv01,+cv02,+cv14,+ss04,+ss07,+ss09";

        # Match kitty scrollback configuration
        scrollback-limit = 10000;
        
        # Match kitty URL detection
        mouse-hide-while-typing = true;

        # TODO: Change around padding to match kitty
        # TODO: Change this to auto update w/ nix-colors
        theme = "tokyonight_night";
      };
    };
  };
}
