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
    
    # Get all users in the wheel group (admin users)
    security.doas.extraRules = 
      let
        wheelUsers = lib.filter (name: 
          lib.elem "wheel" (config.users.users.${name}.extraGroups or [])
        ) (lib.attrNames config.users.users);
      in [
        {
          users = mkDefault wheelUsers;
          keepEnv = mkDefault true;
          persist = mkDefault true;
        }
        {
          users = mkDefault wheelUsers;
          cmd = "tee";
          noPass = mkDefault true;
        }
      ];

    environment.systemPackages =
      [ (pkgs.writeScriptBin "sudo" ''exec doas "$@"'') ];
  };
}
