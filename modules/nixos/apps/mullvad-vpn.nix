{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.apps.mullvad-vpn;
in {
  options.features.apps.mullvad-vpn.enable = mkEnableOption (lib.mdDoc ''
    Mullvad VPN client with GUI application.

    Features:
    - Full Mullvad VPN desktop client
    - System service for VPN connectivity
    - GUI for server selection and settings

    Requires: Mullvad account
  '');

  config = mkIf cfg.enable {
    services.mullvad-vpn.enable = true;
    services.mullvad-vpn.package = pkgs.mullvad-vpn;
  };
}
