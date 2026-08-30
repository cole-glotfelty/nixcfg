{ config, lib, ... }:

with lib;
let cfg = config.features.apps.tailscale;
in {
  options.features.apps.tailscale.enable = mkEnableOption (lib.mdDoc ''
    Tailscale mesh VPN for private device-to-device connectivity.

    Features:
    - WireGuard-based private network between your own devices, no port
      forwarding or public exposure required
    - Lets this Mac reach tailnet-only services (e.g. melchior's WebDAV
      vault server) from anywhere, not just the home LAN

    Note: run `sudo tailscale up` once after rebuild to authenticate this
    host into your tailnet, or use the Tailscale menu-bar app.
  '');

  config = mkIf cfg.enable {
    services.tailscale.enable = true;
  };
}
