{ lib, inputs, outputs, pkgs, ... }:

{
  imports = [ ./users inputs.home-manager.darwinModules.home-manager ];
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs outputs; };
    backupFileExtension = "backup";
  };

  # nixpkgs = {
  #   overlays = [
  #     outputs.overlays.additions
  #     outputs.overlays.modifications
  #     outputs.overlays.stable-packages
  #   ];
  #   config.allowUnfree = true;
  # };

  # nix.settings = {
  #   optimise.automatic = true;
  #   gc = {
  #     automatic = true;
  #     options = "--delete-older-than 30d";
  #   };
  # };
}
