{ config, lib, ... }:

with lib;
let cfg = config.features.desktop.defaultFonts;
in {
  options.features.desktop.defaultFonts = {
    enable = mkEnableOption (lib.mdDoc ''
      System-wide default font configuration for consistent typography.
      
      Font Stack:
      - Serif: Times New Roman → Noto Serif → Liberation Serif
      - Sans Serif: Noto Sans → Liberation Sans
      - Monospace: FiraCode Nerd Font Mono → Liberation Mono  
      - Emoji: Noto Color Emoji
      
      Provides: Consistent font fallbacks across all applications
      Benefits: Programming ligatures, emoji support, cross-platform compatibility
    '');
  };

  config = mkIf cfg.enable {
    fonts.fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [ "Times New Roman" "Noto Serif" "Liberation Serif" ];
        # TODO: Look into Nimbus Sans for sansSerif
        sansSerif = [ "Noto Sans" "Liberation Sans" ];
        monospace = [ "FiraCode Nerd Font Mono" "Liberation Mono" ];
        # TODO: Look into Apple Emoji font for system emoji font
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}
