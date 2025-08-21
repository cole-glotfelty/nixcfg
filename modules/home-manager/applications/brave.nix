{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.applications.brave;
in {
  options.features.applications.brave = {
    enable = mkEnableOption (lib.mdDoc ''
      Brave browser with privacy-focused configuration.
      
      Features:
      - Privacy-first configuration with Brave bloat features disabled via --disable-features
      - Disables: BraveRewards, BraveWallet, BraveNews, BraveToday, BraveTalk, AIChat, BraveVPN
      - Hardware acceleration enabled for better performance
      - Command-line optimizations for privacy and performance
      
      Extension Installation:
      Due to home-manager bug #2216, extensions require manual installation:
      - uBlock Origin: brave://settings/extensions/v2 (Manifest V2 version recommended)
      - Bitwarden: brave://extensions/ or Chrome Web Store
      - Zhongwen: brave://extensions/ or Chrome Web Store  
      - Return YouTube Dislike: brave://extensions/ or Chrome Web Store
      
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
        # Disable Brave-specific features using correct flags
        "--disable-features=BraveRewards,BraveWallet,AIChat,BraveVPN,BraveNews,BraveToday,BraveTalk"
        
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
        "--disable-features=MediaRouter,TranslateUI"
        "--disable-ipc-flooding-protection"
      ];
    };
  };
}