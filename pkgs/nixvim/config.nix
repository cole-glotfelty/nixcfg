{ pkgs, lib, ... }:

{
  # Import the modular configuration files
  imports = [
    ./options.nix
    ./keymaps.nix
    ./plugins
  ];

  # Core nixvim settings (from home-manager default.nix)
  viAlias = true;
  vimAlias = true;
  luaLoader.enable = true;

  colorschemes.tokyonight = {
    enable = true;
    settings = {
      style = "night";
      transparent = if pkgs.stdenv.isDarwin then false else true;
    };
  };
}
