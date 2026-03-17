{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.security.doas;
in {
  options.features.security.doas.enable = mkEnableOption (lib.mdDoc ''
    OpenBSD doas as sudo replacement for privilege escalation.

    Features:
    - Lightweight alternative to sudo
    - Auto-configured for wheel group users
    - Persistent authentication (no repeated password prompts)
    - Passwordless tee for pipe-to-root patterns
    - Provides "sudo" wrapper script for compatibility

    Security: Disables sudo entirely when enabled
  '');

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
