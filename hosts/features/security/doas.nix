{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.security.doas;
in {
  options.features.security.doas.enable =
    mkEnableOption "enable doas";

  config = mkIf cfg.enable {
    # Doas instead of sudo
    security.doas.enable = true;
    security.sudo.enable = false;
    # TODO: change these so it's in terms of a variable
    security.doas.extraRules = [
      {
        users = [ "pharo" ];
        keepEnv = true;
        persist = true;
      }
      {
        users = [ "pharo" ];
        cmd = "tee";
        noPass = true;
      }
    ];

    environment.systemPackages =
      [ (pkgs.writeScriptBin "sudo" ''exec doas "$@"'') ];
  };
}
