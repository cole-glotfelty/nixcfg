{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.applications.brave;
in {
  options.features.applications.brave = {
    enable = mkEnableOption (lib.mdDoc ''
      Brave browser with privacy-focused configuration.
      
      Automated Configuration:
      - Disables via command line: Leo AI Chat, Brave VPN, media router, translate UI
      - Hardware acceleration and performance optimizations enabled
      - Privacy-focused command-line arguments
      
      Manual Configuration Required:
      Most Brave bloat features cannot be disabled via command line and require manual setup:
      - Brave Rewards: Settings > Appearance > Hide Brave Rewards Icon
      - Brave Wallet: brave://flags/#native-brave-wallet > Disabled
      - Brave News: New Tab Page > Customize > Turn off news
      - Brave Talk: Disable in settings when first prompted
      
      Extension Installation:
      Due to home-manager bug #2216, extensions require manual installation:
      - uBlock Origin: brave://settings/extensions/v2 (Manifest V2 version recommended)
      - Bitwarden, Zhongwen, Return YouTube Dislike: Chrome Web Store or brave://extensions/
      
      Extension IDs are configured for reference and potential future fixes.
      
      Dependencies: pkgs.brave
    '');
  };

  config = mkIf cfg.enable {
    programs.chromium = {
      enable = true;
      package = pkgs.brave;
      
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
        # Disable Brave features that actually work via command line
        "--disable-features=AIChat,BraveVPN,MediaRouter,TranslateUI"
        
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