{ config, lib, ... }:

with lib;
let cfg = config.features.apps.devenv;
in {
  options.features.apps.devenv = {
    enable = mkEnableOption (lib.mdDoc ''
      Devenv binary cache for faster development environment builds.
      
      Features:
      - Pre-built devenv packages from official cache
      - Faster setup of development environments
      - Reduces build times for devenv shells and containers
      
      Use case: Systems using devenv for development environments
      Note: The actual devenv package is typically installed via home-manager
      This module only adds the binary cache for performance
    '');
  };

  config = mkIf cfg.enable {
    # Add devenv binary cache for faster builds
    nix.settings = {
      substituters = mkAfter [ "https://devenv.cachix.org" ];
      trusted-public-keys = mkAfter [ 
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=" 
      ];
    };
  };
}