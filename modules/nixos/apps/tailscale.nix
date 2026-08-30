{ config, lib, ... }:

with lib;
let cfg = config.features.apps.tailscale;
in {
  options.features.apps.tailscale.enable = mkEnableOption (lib.mdDoc ''
    Tailscale mesh VPN for private device-to-device connectivity.

    Features:
    - WireGuard-based private network between your own devices, no port
      forwarding or public exposure required
    - Trusts the tailscale0 interface so tailnet peers can reach local
      services without opening firewall ports on the LAN/WAN
    - `tailscale serve` can expose a local service over HTTPS to tailnet
      members only, with an automatically-issued certificate

    Note: run `sudo tailscale up` once after rebuild to authenticate this
    host into your tailnet.
  '');

  config = mkIf cfg.enable {
    services.tailscale.enable = true;
    networking.firewall.trustedInterfaces = [ "tailscale0" ];
    networking.firewall.allowedUDPPorts = [ config.services.tailscale.port ];
  };
}
