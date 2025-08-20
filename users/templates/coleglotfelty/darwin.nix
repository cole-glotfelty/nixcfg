{ config, pkgs, inputs, lib, ... }:

with lib;
let
  hostName = config.networking.hostName;
  userConfigPath = ../../../hosts/${hostName}/users/coleglotfelty.nix;
  userConfigExists = builtins.pathExists userConfigPath;
  # Only enable on Darwin systems
  isDarwin = pkgs.stdenv.isDarwin;
  
in
mkIf (userConfigExists && isDarwin) ({
  users.users.coleglotfelty = {
    name = "coleglotfelty";
    description = "Cole Glotfelty";
    home = "/Users/coleglotfelty";
    packages = [ inputs.home-manager.packages.${pkgs.system}.default ];
  };
  
  home-manager.users.coleglotfelty = import ./.;
} // lib.optionalAttrs isDarwin {
  system.primaryUser = "coleglotfelty";
})
