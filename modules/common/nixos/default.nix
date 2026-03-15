{ lib, inputs, outputs, pkgs, config, ... }:

with lib;

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.disko.nixosModules.disko
    inputs.sops-nix.nixosModules.sops
  ];

  home-manager = {
    useGlobalPkgs = mkDefault true;
    useUserPackages = mkDefault true;
    extraSpecialArgs = { inherit inputs outputs; };
    backupFileExtension = "backup";
  };

  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
    ];
    config = {
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  nix = let 
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
    nixPath = [ "/etc/nix/path" ] ++ [ "nixpkgs=${inputs.nixpkgs}" ]
      ++ lib.mapAttrsToList (flakeName: _: "${flakeName}=flake:${flakeName}")
      flakeInputs;

    settings = {
      experimental-features = mkDefault "nix-command flakes";
      download-buffer-size = mkDefault 134217728;
      # Include root and all wheel group users as trusted
      trusted-users = [ "root" "@wheel" ];
      substituters = mkDefault [
        "https://cache.nixos.org"
        "https://devenv.cachix.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = mkDefault [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };

    optimise.automatic = mkDefault true;
    gc = {
      automatic = mkDefault true;
      dates = mkDefault "weekly";
      options = mkDefault "--delete-older-than 14d";
    };
  };

  # ZSH Default Shell
  users.defaultUserShell = pkgs.zsh;
  environment.binsh = "${pkgs.dash}/bin/dash";
}
