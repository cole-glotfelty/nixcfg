{ inputs, config, lib, outputs, pkgs, ... }:

{
  imports = [ 
    ./user-identity.nix
    ./application-defaults.nix
    ./path-config.nix
  ];

  # nixpkgs configuration is handled by the system when useGlobalPkgs = true

  news.display = "silent";

  nix = {
    package = lib.mkDefault pkgs.nix;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      warn-dirty = false;
    };
  };
}
