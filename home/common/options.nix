{ lib, ... }:

with lib;

{
  # TODO: rename this module or relocate it to make it make sense
  options.custom = {
    hostname = mkOption {
      type = types.str;
      description = "The hostname of the system, used for configuration references";
      default = "nixos"; # Fallback value
    };
  };
}
