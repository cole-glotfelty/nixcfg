{ ... }:

{
  # Host-specific overrides for melchior - template imports are handled automatically
  
  # Configure dual monitor setup for melchior - 1440p left, 1080p right
  features.desktop.hyprland.monitors = [
    "DP-1,2560x1440@154.85,0x0,auto"
    "DP-3,1920x1080@60,2560x0,auto"
  ];
}
