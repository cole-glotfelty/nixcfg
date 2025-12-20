{ config, pkgs, inputs, lib, ... }:

with lib;
let
  hostName = config.networking.hostName;
  userConfigPath = ../../../hosts/${hostName}/users/coleglotfelty.nix;
  userConfigExists = builtins.pathExists userConfigPath;

in mkIf userConfigExists ({
  users.users.coleglotfelty = {
    name = "coleglotfelty";
    description = "Cole Glotfelty";
    home = "/Users/coleglotfelty";
    packages = [ inputs.home-manager.packages.${pkgs.stdenv.hostPlatform.system}.default ];
  };

  home-manager.users.coleglotfelty = import ./.;
} // {
  system.primaryUser = "coleglotfelty";
})
