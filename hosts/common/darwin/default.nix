{ lib, inputs, outputs, pkgs, ... }:

with lib;

{
  imports = [ ./users inputs.home-manager.darwinModules.home-manager ];
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
    config.allowUnfree = mkDefault true;
  };

  nix.settings = {
    optimise.automatic = mkDefault true;
    gc = {
      automatic = mkDefault true;
      options = mkDefault "--delete-older-than 30d";
    };
  };
}
