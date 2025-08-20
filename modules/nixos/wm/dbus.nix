{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.wm.dbus;
in {
  options.features.wm.dbus.enable = mkEnableOption "enable dbus";

  config = mkIf cfg.enable {
    services.dbus = {
      enable = true;
      implementation = "broker";
      packages = [ pkgs.dconf ];
    };

    programs.dconf = { enable = true; };
  };
}
