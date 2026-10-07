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

    # Mullvad's kill switch blocks all traffic outside its own tunnel,
    # and its "local network sharing" allowlist doesn't cover Tailscale's
    # CGNAT range (100.64.0.0/10) so it can't be allowlisted that way.
    # The GUI's split tunneling view only launches desktop apps through
    # mullvad-exclude, which doesn't help a systemd service started at
    # boot. Launch tailscaled through mullvad-exclude directly instead,
    # via a drop-in that clears and replaces its packaged ExecStart.
    systemd.services.tailscaled = mkIf config.features.apps.mullvad-vpn.enable {
      after = [ "mullvad-daemon.service" ];
      wants = [ "mullvad-daemon.service" ];
      serviceConfig.ExecStart = [
        ""
        "${config.security.wrapperDir}/mullvad-exclude ${config.services.tailscale.package}/bin/tailscaled --state=/var/lib/tailscale/tailscaled.state --socket=/run/tailscale/tailscaled.sock --port=\${PORT} $FLAGS"
      ];
    };
  };
}
