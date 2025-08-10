# HOST: alpha-1-5
{ ... }:

{
  imports = [ ../common/darwin ./configuration.nix ../features/homebrew ../features/apps ];

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
