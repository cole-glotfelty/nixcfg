{ config, lib, pkgs, ... }:

{
  home.username = lib.mkDefault "coleglotfelty";
  home.homeDirectory = lib.mkDefault "/Users/${config.home.username}";

  # The state version is required and should stay at the version you
  # originally installed.
  home.stateVersion = "24.11";

  # Configure user identity and preferences (user-level priority)
  custom.user = {
    name = lib.mkOverride 500 "Cole Glotfelty";
    email = lib.mkOverride 500 "git@postagepaid.cc";
  };

  custom.defaults = {
    terminal = lib.mkOverride 500 "kitty";
    browser = lib.mkOverride 500 "firefox";  # or whatever browser you prefer on macOS
    editor = lib.mkOverride 500 "nvim";
    copyCommand = lib.mkOverride 500 "pbcopy";  # macOS clipboard command
  };

  home.sessionVariables = {
    EDITOR = config.custom.defaults.editor;
    TERMINAL = config.custom.defaults.terminal;
    NIX_PATH = "nixpkgs=channel:nixos-unstable";
    NIX_LOG = "info";
    PROJECT_DIRS = "$HOME ${config.custom.paths.projects} $HOME/Git";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
