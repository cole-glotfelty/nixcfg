{ config, lib, pkgs, ... }:

{
  home.username = lib.mkDefault "coleglotfelty";
  home.homeDirectory = lib.mkDefault "/Users/${config.home.username}";

  # The state version is required and should stay at the version you
  # originally installed.
  home.stateVersion = "24.11";

  home.sessionVariables = {
    EDITOR = "nvim";
    TERMINAL = "kitty";
    NIX_PATH = "nixpkgs=channel:nixos-unstable";
    NIX_LOG = "info";
    PROJECT_DIRS = "$HOME $HOME/Projects $HOME/Git";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
