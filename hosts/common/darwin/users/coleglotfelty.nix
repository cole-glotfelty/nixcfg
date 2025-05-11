{ config, pkgs, inputs, outputs, ... }:

{
  users.users.coleglotfelty = {
    name = "coleglotfelty";
    description = "Cole Glotfelty";
    home = "/Users/coleglotfelty";
    packages = [ inputs.home-manager.packages.${pkgs.system}.default ];
  };

  home-manager.users.coleglotfelty =
      import ../../../../home/darwin/coleglotfelty/${config.networking.hostName}.nix;
}
