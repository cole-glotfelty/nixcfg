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
        # Core programming and system fonts
        nerd-fonts.fira-code
        corefonts
        liberation_ttf
        
        # High-quality TeX Gyre fonts (includes Nimbus Sans equivalent)
        gyre-fonts
        
        # CJK language support
        source-han-sans
        source-han-serif
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        
        # Unicode support (emoji temporarily disabled for testing)
        noto-fonts
        # noto-fonts-emoji  # Temporarily disabled to test Apple Color Emoji
        noto-fonts-extra
        
        # Custom Apple Color Emoji font
        pkgs.apple-color-emoji
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
        localConf = ''
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
            
            <!-- Default Chinese text to sans-serif fonts -->
            <match target="pattern">
              <test name="lang" compare="contains">
                <string>zh</string>
              </test>
              <test name="family">
                <string>serif</string>
              </test>
              <edit name="family" mode="prepend" binding="strong">
                <string>Source Han Sans</string>
              </edit>
            </match>
            
            <!-- Ensure Chinese sans-serif preference -->
            <match target="pattern">
              <test name="lang" compare="contains">
                <string>zh</string>
              </test>
              <test name="family">
                <string>sans-serif</string>
              </test>
              <edit name="family" mode="prepend" binding="strong">
                <string>Source Han Sans</string>
              </edit>
            </match>
            
            <!-- Force Apple Color Emoji for all emoji requests -->
            <match target="pattern">
              <test name="family" compare="contains">
                <string>emoji</string>
              </test>
              <edit name="family" mode="prepend" binding="strong">
                <string>Apple Color Emoji</string>
              </edit>
            </match>
            
            <!-- Ensure Apple Color Emoji for common emoji font requests -->
            <match target="pattern">
              <test name="family">
                <string>Segoe UI Emoji</string>
              </test>
              <edit name="family" mode="assign" binding="strong">
                <string>Apple Color Emoji</string>
              </edit>
            </match>
            <match target="pattern">
              <test name="family">
                <string>Noto Color Emoji</string>
              </test>
              <edit name="family" mode="prepend" binding="strong">
                <string>Apple Color Emoji</string>
              </edit>
            </match>
          </fontconfig>
        '';
      };
    };
  };
}
