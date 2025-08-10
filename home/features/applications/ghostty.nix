{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.applications.ghostty;
in {
  options.features.applications.ghostty = {
    enable = mkEnableOption (lib.mdDoc ''
      Ghostty terminal emulator with modern GPU acceleration and shell integration.
      
      Features:
      - FiraCode Nerd Font with programming ligatures and icons  
      - Tokyo Night theme for consistent dark mode experience
      - Shell integration for Zsh and Bash (no cursor/sudo modifications)
      - Block cursor with no blinking for focused editing
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
        font-size = 11;

        # TODO: Change around padding to match kitty
        # TODO: Change this to auto update w/ nix-colors
        theme = "tokyonight_night";
      };
    };
  };
}
