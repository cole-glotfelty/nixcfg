{ config, lib, inputs, ... }:

with lib;
let
  cfg = config.features.security.blocklist;
  blocklist = builtins.readFile
    "${inputs.blocklist-hosts}/alternates/gambling-porn/hosts";

in {
  options.features.security.blocklist.enable = mkEnableOption "enable blocklist";

  config = mkIf cfg.enable {
    networking.extraHosts = ''
      "${blocklist}"
    '';

  };
}
