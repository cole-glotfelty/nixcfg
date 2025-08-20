{ lib, config, ... }:

{
  imports = [
    ./home.nix
    ../../common
    ../../../modules/home-manager/cli
    ../../../modules/home-manager/applications
  ];
  # Host-specific overrides are automatically included by the flake

  features = {
    cli = {
      zsh.enable = lib.mkDefault true;
      fzf.enable = lib.mkDefault true;
      git.enable = lib.mkDefault true;
      tmux.enable = lib.mkDefault true;
      zoxide.enable = lib.mkDefault true;
      nixvim.enable = lib.mkDefault true;
      devenv.enable = lib.mkDefault true;
      sops.enable = lib.mkDefault false;
    };

    applications = {
      kitty.enable = lib.mkDefault true;
      browsers.enable = lib.mkDefault true;
    };
  };
}
