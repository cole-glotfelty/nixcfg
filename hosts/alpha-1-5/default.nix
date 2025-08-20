# HOST: alpha-1-5
{ ... }:

rec {
  # Metadata for flake auto-generation
  _meta = {
    system = "darwin";
    architecture = "aarch64-darwin";
    users = [ "coleglotfelty" ];
  };

  imports = [
    (../../modules/common + "/${_meta.system}")
    ./configuration.nix
    ../../modules/darwin/homebrew
    ../../modules/nixos/apps
  ];

  features = {
    homebrew = {
      enable = true;
      casks.enable = true;
    };
    
    apps = {
      devenv.enable = true;
      mullvad-vpn.enable = false;
      steam.enable = false;
      nixd.enable = false;
    };
  };
}
