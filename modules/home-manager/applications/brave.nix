{ config, lib, pkgs, ... }:

with lib;
let 
  cfg = config.features.applications.brave;
in {
  options.features.applications.brave = {
    enable = mkEnableOption (lib.mdDoc ''
      Brave browser with privacy-focused configuration.
      
      Automated Configuration:
      - System-level enterprise policies disable: Rewards, Wallet, News, Talk, VPN, AI Chat, telemetry
      - Command line flags disable: Media router, translate UI
      - Hardware acceleration and performance optimizations enabled
      - Privacy-focused command-line arguments
      
      Extension Installation:
      Due to home-manager bug #2216, extensions require manual installation:
      - uBlock Origin: brave://settings/extensions/v2 (Manifest V2 version recommended)
      - Bitwarden, Zhongwen, Return YouTube Dislike: Chrome Web Store or brave://extensions/
      
      Extension IDs are configured for reference and potential future fixes.
      
      Dependencies: pkgs.brave
      System Module: Automatically enables system-level Brave enterprise policies
    '');
  };

  config = mkIf cfg.enable {
    # Enterprise policies are handled by the system-level Brave policies module
    # which auto-activates when this home-manager module is enabled
    
    programs.chromium = {
      enable = true;
      package = pkgs.brave;
      
      # Search engine configuration handled at NixOS system level
      
      # NOTE: Due to home-manager bug #2216, extensions may not auto-install for Brave
      # Extensions are installed to wrong directory (.config/brave/ vs .config/BraveSoftware/Brave-Browser/)
      # Manual installation recommended: brave://extensions/ or chrome://extensions/
      extensions = mkDefault [
        {
          # uBlock Origin - Ad and tracker blocker
          # Manual install: brave://settings/extensions/v2 (Manifest V2) or Chrome Web Store
          id = "cjpalhdlnbpafiamejdnhcphjbkeiagm";
        }
        {
          # Bitwarden - Password manager
          id = "nngceckbapebfimnlniiiahkandclblb";
        }
        {
          # Zhongwen - Chinese-English Dictionary
          id = "kkmlkkjojmombglmlpbpapmhcaljjkde";
        }
        {
          # Return YouTube Dislike - Restores YouTube dislike counts
          id = "gebbhagfogifgggkldgodflihgfeippi";
        }
      ];

      commandLineArgs = mkDefault [
        # Wayland and IME support
        "--enable-wayland-ime"
        "--gtk-version=4"
        "--ozone-platform=wayland"

        # CJK font rendering fix (disable GPU compositing if fonts render blank)
        # Remove this line if CJK works, to restore GPU acceleration
        "--disable-gpu-compositing"

        # Disable Brave features that work via command line (limited effectiveness)
        "--disable-features=MediaRouter,TranslateUI"

        # Privacy and security enhancements
        "--disable-background-networking"
        "--disable-background-timer-throttling"
        "--disable-renderer-backgrounding"
        "--disable-backgrounding-occluded-windows"
        "--disable-component-extensions-with-background-pages"
        
        # Performance optimizations
        "--enable-gpu-rasterization"
        "--enable-zero-copy"
        "--ignore-gpu-blocklist"
        
        # Additional privacy flags
        "--disable-default-apps"
        "--disable-ipc-flooding-protection"
      ];
    };
  };
}