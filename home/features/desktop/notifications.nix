{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.desktop.notifications;
in {
  options.features.desktop.notifications.enable =
    mkEnableOption "enable notifications via Dunst";

  config = mkIf cfg.enable {
    # TODO: Is this necissary?
    home.packages = with pkgs; [ libnotify ];
    services.dunst = { enable = true; };
  };
}
