{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.wm.fonts;
in {
  options.features.wm.fonts = {
    enable = mkEnableOption (lib.mdDoc ''
      System font configuration with comprehensive Unicode and emoji support.
      
      Features:
      - FiraCode Nerd Font with programming ligatures and icons
      - Microsoft Core Fonts for web compatibility
      - Liberation fonts as system-ui replacements
      - Complete CJK (Chinese/Japanese/Korean) font coverage
      - Emoji support with Noto Emoji fonts
      - Optimized font rendering with anti-aliasing and hinting
      - Web font fallback configuration for consistent spacing
      
      Use case: Desktop systems requiring text rendering and font support
      Dependencies: GUI applications, desktop environment
    '');
  };

  config = mkIf cfg.enable {
    fonts = {
      packages = mkDefault (with pkgs; [
        # TODO: Look into more font packages
        # TODO: Look into fontconfig option
        # TODO: Look into Apple Emoji font for system emoji font
        nerd-fonts.fira-code
        corefonts
        liberation_ttf
        source-han-sans
        source-han-serif
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        noto-fonts-emoji
        noto-fonts-extra
      ]);

      fontconfig = {
        enable = mkDefault true;
      };
    };
  };
}
