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
        includeUserConf = mkDefault true;

        # Font rendering settings to fix spacing issues
        antialias = mkDefault true;
        hinting = {
          enable = mkDefault true;
          style = mkDefault "slight"; # Preserves font metrics better than "full"
          autohint = mkDefault false; # Prefer built-in hinting instructions
        };

        # Subpixel rendering options (for LCD screens)
        subpixel = {
          rgba = mkDefault "rgb"; # Common LCD pixel layout
          lcdfilter = mkDefault "default"; # Standard filtering
        };

        # Bitmap font handling
        allowBitmaps = mkDefault false; # Disable bitmap fonts which cause spacing issues
        useEmbeddedBitmaps = mkDefault false;

        # Advanced configurations for spacing-related issues
        localConf = mkDefault ''
          <?xml version="1.0"?>
          <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
          <fontconfig>
            <!-- Fix spacing in web applications by providing consistent substitutions -->
            <match target="pattern">
              <test qual="any" name="family">
                <string>system-ui</string>
              </test>
              <edit name="family" mode="assign" binding="same">
                <string>Liberation Sans</string>
              </edit>
            </match>
            
            <!-- When websites request Apple fonts -->
            <match target="pattern">
              <test qual="any" name="family">
                <string>-apple-system</string>
              </test>
              <edit name="family" mode="assign" binding="same">
                <string>Liberation Sans</string>
              </edit>
            </match>
            <match target="pattern">
              <test qual="any" name="family">
                <string>San Francisco</string>
              </test>
              <edit name="family" mode="assign" binding="same">
                <string>Liberation Sans</string>
              </edit>
            </match>

            <!-- Apple CJK font substitutions -->
            <match target="pattern">
              <test qual="any" name="family"><string>PingFang SC</string></test>
              <edit name="family" mode="assign" binding="same"><string>Noto Sans CJK SC</string></edit>
            </match>
            <match target="pattern">
              <test qual="any" name="family"><string>PingFang TC</string></test>
              <edit name="family" mode="assign" binding="same"><string>Noto Sans CJK TC</string></edit>
            </match>
            <match target="pattern">
              <test qual="any" name="family"><string>PingFang HK</string></test>
              <edit name="family" mode="assign" binding="same"><string>Noto Sans CJK HK</string></edit>
            </match>
            <match target="pattern">
              <test qual="any" name="family"><string>Hiragino Sans</string></test>
              <edit name="family" mode="assign" binding="same"><string>Noto Sans CJK JP</string></edit>
            </match>
            <match target="pattern">
              <test qual="any" name="family"><string>Hiragino Kaku Gothic Pro</string></test>
              <edit name="family" mode="assign" binding="same"><string>Noto Sans CJK JP</string></edit>
            </match>
            <match target="pattern">
              <test qual="any" name="family"><string>Hiragino Kaku Gothic ProN</string></test>
              <edit name="family" mode="assign" binding="same"><string>Noto Sans CJK JP</string></edit>
            </match>
            <match target="pattern">
              <test qual="any" name="family"><string>Apple SD Gothic Neo</string></test>
              <edit name="family" mode="assign" binding="same"><string>Noto Sans CJK KR</string></edit>
            </match>

            <!-- Prefer sans-serif CJK fonts in the sans-serif fallback chain -->
            <alias>
              <family>sans-serif</family>
              <prefer>
                <family>Noto Sans CJK JP</family>
                <family>Noto Sans CJK SC</family>
                <family>Noto Sans CJK TC</family>
                <family>Noto Sans CJK KR</family>
              </prefer>
            </alias>

            <!-- Prefer monospace CJK fonts in the monospace fallback chain (for terminals) -->
            <alias>
              <family>monospace</family>
              <prefer>
                <family>Noto Sans Mono CJK JP</family>
                <family>Noto Sans Mono CJK SC</family>
                <family>Noto Sans Mono CJK TC</family>
                <family>Noto Sans Mono CJK KR</family>
              </prefer>
            </alias>

            <!-- Override serif CJK fallback to use sans-serif (prefer consistent sans look) -->
            <alias>
              <family>serif</family>
              <prefer>
                <family>Noto Sans CJK JP</family>
                <family>Noto Sans CJK SC</family>
                <family>Noto Sans CJK TC</family>
                <family>Noto Sans CJK KR</family>
              </prefer>
            </alias>

            <!-- Language-specific CJK sans-serif defaults -->
            <match target="pattern">
              <test name="lang" compare="contains"><string>ja</string></test>
              <edit name="family" mode="prepend" binding="strong">
                <string>Noto Sans CJK JP</string>
              </edit>
            </match>
            <match target="pattern">
              <test name="lang" compare="contains"><string>zh-CN</string></test>
              <edit name="family" mode="prepend" binding="strong">
                <string>Noto Sans CJK SC</string>
              </edit>
            </match>
            <match target="pattern">
              <test name="lang" compare="contains"><string>zh-TW</string></test>
              <edit name="family" mode="prepend" binding="strong">
                <string>Noto Sans CJK TC</string>
              </edit>
            </match>
            <match target="pattern">
              <test name="lang" compare="contains"><string>ko</string></test>
              <edit name="family" mode="prepend" binding="strong">
                <string>Noto Sans CJK KR</string>
              </edit>
            </match>

            <!-- Language-specific CJK monospace defaults -->
            <match target="pattern">
              <test name="lang" compare="contains"><string>ja</string></test>
              <edit name="family" mode="prepend" binding="strong">
                <string>Noto Sans Mono CJK JP</string>
              </edit>
            </match>
            <match target="pattern">
              <test name="lang" compare="contains"><string>zh-CN</string></test>
              <edit name="family" mode="prepend" binding="strong">
                <string>Noto Sans Mono CJK SC</string>
              </edit>
            </match>
            <match target="pattern">
              <test name="lang" compare="contains"><string>zh-TW</string></test>
              <edit name="family" mode="prepend" binding="strong">
                <string>Noto Sans Mono CJK TC</string>
              </edit>
            </match>
            <match target="pattern">
              <test name="lang" compare="contains"><string>ko</string></test>
              <edit name="family" mode="prepend" binding="strong">
                <string>Noto Sans Mono CJK KR</string>
              </edit>
            </match>
          </fontconfig>
        '';
      };
    };
  };
}
