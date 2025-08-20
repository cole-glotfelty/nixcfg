{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.apps.mullvad-vpn;
in {
  options.features.apps.mullvad-vpn.enable = mkEnableOption "enable mullvad-vpn";

  config = mkIf cfg.enable {
    services.mullvad-vpn.enable = true;
    services.mullvad-vpn.package = pkgs.mullvad-vpn;
  };
}
