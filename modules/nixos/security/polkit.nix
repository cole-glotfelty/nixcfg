{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.security.polkit;
in {
  options.features.security.polkit = {
    enable = mkEnableOption (lib.mdDoc ''
      PolicyKit authorization framework for privilege escalation.
      
      Features:
      - System-wide privilege escalation management
      - GUI authentication dialogs for desktop applications
      - Fine-grained access control for system operations
      - Integration with desktop environments and polkit agents
      
      Use case: Desktop systems requiring privilege escalation dialogs
      Dependencies: Desktop environment or window manager
      Works with: GNOME, KDE, Hyprland polkit agents
    '');
  };

  config = mkIf cfg.enable {
    security.polkit = {
      enable = true;
    };
  };
}
