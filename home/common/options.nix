{ lib, ... }:

with lib;

{
  options.custom = {
    hostname = mkOption {
      type = types.str;
      description = "The hostname of the system, used for configuration references";
      default = "nixos"; # Fallback value
    };
  };
}
