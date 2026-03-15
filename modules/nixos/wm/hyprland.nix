{ config, lib, inputs, pkgs, ... }:

with lib;
let
  # pkgs-hyprland =
  #   inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in {
  # This module automatically enables when any home-manager user has Hyprland enabled
  # No manual configuration needed - it's purely reactive to user preferences

  config = lib.mkIfAnyHMOpt config (hmCfg: hmCfg.features.desktop.hyprland.enable or false) {
    assertions = [
      {
        assertion = !pkgs.stdenv.isDarwin;
        message = ''
          Hyprland module is enabled but you're running on macOS.
          
          Hyprland is a Linux-only Wayland compositor and is not available on macOS.
          For macOS window management, consider using built-in window management
          or third-party tools like Rectangle, Amethyst, or yabai.
          
          Disable this module: features.wm.hyprland.enable = false;
        '';
      }
    ];

    # Add Hyprland binary cache for faster builds
    nix.settings = {
      substituters = mkAfter [ "https://hyprland.cachix.org" ];
      trusted-public-keys = mkAfter [ 
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" 
      ];
    };

    # Security
    security = { pam.services.login.enableGnomeKeyring = true; };

    # Hints electron apps to use Wayland
    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      WLR_NO_HARDWARE_CURSORS = "1";
    };

    # Display Manager
    services.displayManager.ly.enable = true;

    # Setup Polkit
    environment.systemPackages = with pkgs; [ hyprpolkitagent ];

    systemd.user.services.hyprpolkitagent = {
      description = "Hyprland Polkit Agent";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.hyprpolkitagent}/bin/hyprpolkitagent";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };

    programs.hyprland = {
      enable = true;
      # package = inputs.hyprland.packages.${pkgs.system}.hyprland;
      xwayland.enable = true;
      # portalPackage = pkgs-hyprland.xdg-desktop-portal-hyprland;
      # withUWSM = true;
    };

  };
}
