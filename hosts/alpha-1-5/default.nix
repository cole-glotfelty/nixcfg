# HOST: alpha-1-5
{ ... }:

{
  imports = [ ../common/darwin ./configuration.nix ../features/homebrew ];

  features = {
    homebrew = {
      enable = true;
      casks.enable = true;
    };
  };
}
