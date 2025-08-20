{ ... }:

{
  # Host-specific overrides for casper - template imports are handled automatically
  
  # Configure dual monitor setup for casper
  features.desktop.hyprland.monitors = [
    "HDMI-A-1,1920x1080@75,auto,auto"
    "HDMI-A-2,1920x1080@75,auto,auto"
  ];
}
