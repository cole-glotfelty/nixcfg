{ config, lib, ... }:

with lib;
let cfg = config.features.desktop.notifications;
in {
  options.features.desktop.notifications.enable = mkEnableOption "enable notifications via Dunst";

  config = mkIf cfg.enable {
    services.dunst = {
      enable = true;
    };
  };
}
