{ config, lib, ... }:

with lib;
let cfg = config.features.style.fonts;
in {
  options.features.style.fonts = {
    enable = mkEnableOption (lib.mdDoc ''
      System-wide default font configuration for consistent typography.
      
      Font Stack:
      - Serif: Times New Roman → Noto Serif → Liberation Serif
      - Sans Serif: TeX Gyre Heros → Noto Sans → Liberation Sans
      - Monospace: FiraCode Nerd Font Mono → Liberation Mono  
      - Emoji: Apple Color Emoji → Noto Color Emoji
      
      Provides: Consistent font fallbacks across all applications
      Benefits: Programming ligatures, emoji support, cross-platform compatibility
    '');
  };

  config = mkIf cfg.enable {
    fonts.fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [
          "Times New Roman"
          "Noto Serif"
          "Noto Serif CJK JP"
          "Noto Serif CJK SC"
          "Noto Serif CJK TC"
          "Noto Serif CJK KR"
        ];
        sansSerif = [
          "TeX Gyre Heros"
          "Noto Sans"
          "Noto Sans CJK JP"
          "Noto Sans CJK SC"
          "Noto Sans CJK TC"
          "Noto Sans CJK KR"
        ];
        monospace = [
          "FiraCode Nerd Font Mono"
          "Noto Sans Mono CJK JP"
          "Noto Sans Mono CJK SC"
          "Noto Sans Mono CJK TC"
          "Noto Sans Mono CJK KR"
        ];
        emoji = [ "Apple Color Emoji" "Noto Color Emoji" ];
      };
    };
  };
}
