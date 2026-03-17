{ config, lib, inputs, ... }:

with lib;
let
  cfg = config.features.security.blocklist;
  blocklist = builtins.readFile
    "${inputs.blocklist-hosts}/alternates/gambling-porn/hosts";

in {
  options.features.security.blocklist.enable = mkEnableOption (lib.mdDoc ''
    Host-based domain blocking via /etc/hosts.

    Features:
    - Blocks gambling and adult content domains
    - Uses StevenBlack unified hosts blocklist
    - System-wide blocking for all applications

    Source: blocklist-hosts flake input
  '');

  config = mkIf cfg.enable {
    networking.extraHosts = ''
      "${blocklist}"
    '';

  };
}
