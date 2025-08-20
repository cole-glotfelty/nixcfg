{ ... }:

{
  # Host-specific overrides for melchior - template imports are handled automatically
  
  # Configure dual monitor setup for melchior  
  features.desktop.hyprland.monitors = [
    "DP-1,2560x1440@154.85,auto,auto"
    "DP-4,1920x1080@60,auto,auto"
  ];
}
