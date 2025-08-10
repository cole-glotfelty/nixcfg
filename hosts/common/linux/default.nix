{ lib, inputs, outputs, pkgs, config, ... }:

with lib;

{
  imports = [
    ./users
    inputs.home-manager.nixosModules.home-manager
    inputs.disko.nixosModules.disko
    inputs.sops-nix.nixosModules.sops
  ];

  home-manager = {
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs outputs; };
    backupFileExtension = "backup";
  };

  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.stable-packages
    ];
    config.allowUnfree = true;
  };

  nix = let 
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
    # Automatically get all users in the wheel group (admin users)
    wheelUsers = lib.filter (name: 
      lib.elem "wheel" (config.users.users.${name}.extraGroups or [])
    ) (lib.attrNames config.users.users);
  in {
    registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
    nixPath = [ "/etc/nix/path" ] ++ [ "nixpkgs=${inputs.nixpkgs}" ]
      ++ lib.mapAttrsToList (flakeName: _: "${flakeName}=flake:${flakeName}")
      flakeInputs;

    settings = {
      experimental-features = mkDefault "nix-command flakes";
      download-buffer-size = mkDefault 134217728;
      # Dynamically include root + all wheel group users as trusted
      trusted-users = mkDefault ([ "root" ] ++ wheelUsers);
      substituters = mkDefault [
        "https://cache.nixos.org"
      ];
      trusted-public-keys = mkDefault [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
    };

    optimise.automatic = mkDefault true;
    gc = {
      automatic = mkDefault true;
      options = mkDefault "--delete-older-than 30d";
    };
  };

  # ZSH Default Shell
  users.defaultUserShell = pkgs.zsh;
}
