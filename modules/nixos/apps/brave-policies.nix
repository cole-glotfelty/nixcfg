{ config, lib, pkgs, ... }:

with lib;
let
  # Enterprise policies configuration for Brave
  # Only using confirmed working policy names with correct value types
  bravePolicy = {
    # Brave-specific policies
    BraveRewardsDisabled = true;       # Disable Brave Rewards (boolean)
    BraveWalletDisabled = true;        # Disable Brave Wallet and web3 features (boolean)
    BraveVPNDisabled = 1;              # Disable Brave VPN (integer, as confirmed working)
    BraveAIChatEnabled = false;        # Disable Leo AI Chat (boolean)
    BraveTalkDisabled = true;          # Disable Brave Talk (trying boolean, may not exist)
    BraveNewsDisabled = true;          # Disable Brave News (available in 1.82.x+)
    
  };
  
  # Policy file content for Linux (JSON)
  linuxPolicyContent = builtins.toJSON bravePolicy;
  
  # Policy file content for macOS (plist XML)
  macOSPolicyContent = ''
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
        <key>BraveRewardsDisabled</key>
        <true/>
        <key>BraveWalletDisabled</key>
        <true/>
        <key>BraveVPNDisabled</key>
        <integer>1</integer>
        <key>BraveAIChatEnabled</key>
        <false/>
        <key>BraveTalkDisabled</key>
        <true/>
        <key>BraveNewsDisabled</key>
        <true/>
    </dict>
    </plist>
  '';
in {
  # This module automatically enables when any home-manager user has Brave enabled
  # No manual configuration needed - it's purely reactive to user preferences

  config = lib.mkIfAnyHMOpt config (hmCfg: hmCfg.features.applications.brave.enable or false) {
    # Linux: Create Brave enterprise policies in /etc/brave/policies/managed/
    environment.etc = lib.mkIf pkgs.stdenv.isLinux {
      "brave/policies/managed/nixos-brave-policies.json" = {
        mode = "0644";
        text = linuxPolicyContent;
      };
    };

    # macOS: Create Brave enterprise policies in /Library/Managed Preferences/
    system.activationScripts = lib.mkIf pkgs.stdenv.isDarwin {
      bravePolicies = {
        text = ''
          # Create Brave policies for macOS
          mkdir -p "/Library/Managed Preferences"
          cat > "/Library/Managed Preferences/com.brave.Browser.plist" << 'EOF'
          ${macOSPolicyContent}
          EOF
          chown root:wheel "/Library/Managed Preferences/com.brave.Browser.plist"
          chmod 644 "/Library/Managed Preferences/com.brave.Browser.plist"
        '';
        deps = [];
      };
    };

    # Configure DuckDuckGo as default search engine (auto-enables when Brave HM module enabled)
    programs.chromium = {
      enable = true;
      defaultSearchProviderEnabled = true;
      defaultSearchProviderSearchURL = "https://duckduckgo.com/?q={searchTerms}";
      defaultSearchProviderSuggestURL = "https://duckduckgo.com/ac/?q={searchTerms}&type=list";
    };
  };
}