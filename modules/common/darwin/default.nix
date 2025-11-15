{ lib, inputs, outputs, pkgs, config, ... }:

with lib;

{
  imports = [ 
    inputs.home-manager.darwinModules.home-manager 
  ];

  home-manager = {
    useGlobalPkgs = mkDefault true;
    useUserPackages = mkDefault true;
    extraSpecialArgs = { inherit inputs outputs; };
    backupFileExtension = mkDefault "backup";
  };

  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.stable-packages
    ];
    config = {
      allowUnfree = mkDefault true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = mkDefault (_: true);
    };
  };

  nix= {
    optimise.automatic = mkDefault true;
    gc = {
      automatic = mkDefault true;
      options = mkDefault "--delete-older-than 30d";
    };
  };
}
