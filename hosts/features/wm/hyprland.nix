{ config, lib, inputs, pkgs, ... }:

with lib;
let
  cfg = config.features.wm.hyprland;
  # pkgs-hyprland =
  #   inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in {
  options.features.wm.hyprland.enable =
    mkEnableOption "enable hyprland system level settings";

  config = mkIf cfg.enable {

    # Security
    security = { pam.services.login.enableGnomeKeyring = true; };

    # Hints electron apps to use Wayland
    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      WLR_NO_HARDWARE_CURSORS = "1";
    };

    # Display Manager
    # TODO: Reference Sascha Koenig's Setup
    # TODO: I shouldn't need this line, but I do
    # figure out what's making lightDM get installed (pam.d)
    # services.xserver.displayManager.lightdm.enable = mkForce false;
    # services.xserver.displayManager.lightdm.enable = false;
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
