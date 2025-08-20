{ inputs, lib, config, ... }:

let
  cfg = config.features.cli.sops;
in
{
  imports = [ inputs.sops-nix.homeManagerModules.sops ];
  
  options.features.cli.sops.enable = lib.mkEnableOption "enable user-level sops";

  config = lib.mkIf cfg.enable {
    # User-level sops configuration
    # Future user-specific secrets (SSH keys, GPG, etc.) can be added here
  };
}