{ pkgs, nixvim, ... }:

let
  nixvimLib = nixvim.lib.${pkgs.stdenv.hostPlatform.system};
  nixvim' = nixvim.legacyPackages.${pkgs.stdenv.hostPlatform.system};

  # Pure standalone nixvim configuration
  nixvimConfig = import ./config.nix { inherit pkgs; lib = pkgs.lib; };

  nixvimModule = {
    inherit pkgs;
    module = nixvimConfig;
    extraSpecialArgs = { };
  };

  # Build the nixvim package
  nixvimPackage = nixvim'.makeNixvimWithModule nixvimModule;
in
# Return the package with config exposed as an attribute
nixvimPackage.overrideAttrs (oldAttrs: {
  passthru = (oldAttrs.passthru or {}) // {
    # Expose the configuration for home-manager consumption
    config = nixvimConfig;
  };
})