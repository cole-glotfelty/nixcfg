{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.applications.brave;
in {
  options.features.applications.brave = {
    enable = mkEnableOption (lib.mdDoc ''
      Brave browser with privacy-focused configuration and essential extensions.
      
      Features:
      - Privacy-first configuration with Brave bloat features disabled
      - Essential extensions: uBlock Origin, Bitwarden, Zhongwen, Return YouTube Dislike
      - Hardware acceleration enabled for better performance
      - Command-line optimizations for privacy and performance
      
      Note: uBlock Origin may also be available through Brave's internal Manifest V2 system
      at brave://settings/extensions/v2 for more reliable installation.
      
      Dependencies: pkgs.brave
    '');
  };

  config = mkIf cfg.enable {
    programs.chromium = {
      enable = true;
      package = pkgs.brave;
      
      extensions = mkDefault [
        {
          # uBlock Origin - Ad and tracker blocker
          # Note: Also available via brave://settings/extensions/v2 for more reliable installation
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
        # Disable Brave-specific bloat features
        "--disable-brave-rewards"
        "--disable-brave-ads"
        "--disable-brave-wallet"
        "--disable-brave-news"
        "--disable-brave-search"
        "--disable-brave-talk"
        
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
        "--disable-extensions-except"
        "--disable-features=MediaRouter"
        "--disable-ipc-flooding-protection"
      ];
    };
  };
}