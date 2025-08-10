{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.applications.messaging;
in {
  options.features.applications.messaging = {
    enable = mkEnableOption (lib.mdDoc ''
      Communication and messaging applications suite.
      
      Includes:
      - Discord: Gaming and community chat
      - Slack: Professional team communication
      - Signal: Privacy-focused encrypted messaging
      - Zoom: Video conferencing and meetings
      - Thunderbird: Full-featured email client
      
      Use case: Complete communication setup for work, gaming, and personal use
      Integrates with: custom.defaults.mailClient (for Thunderbird)
    '');
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # Text/Voice
      discord
      slack
      signal-desktop

      # Video Calling
      zoom-us

      # Email
      thunderbird
    ];

    # Email
    # programs.thunderbird = {
    #   enable = true;
    # };
  };
}
