{ config, lib, inputs, outputs, pkgs, ... }:

with lib;
let cfg = config.features.cli.nixvim;
in {
  imports = [
    inputs.nixvim.homeModules.nixvim
  ];

  options.features.cli.nixvim.enable = mkEnableOption (lib.mdDoc ''
    NixVim Neovim configuration with full IDE features.

    Features:
    - Standalone-first architecture (also runnable via nix run .#nixvim)
    - LSP, Treesitter, completion, and formatting
    - TokyoNight colorscheme
    - Consumes config from pkgs/nixvim/

    Disables basic vim module when enabled
  '');

  config = mkIf cfg.enable {
    programs.vim.enable = mkForce false;
    programs.nixvim = outputs.packages.${pkgs.stdenv.hostPlatform.system}.nixvim.passthru.config // {
      enable = true;
      # Home-manager specific settings that aren't in standalone
      vimdiffAlias = true; # this could cause problems
      nixpkgs.source = inputs.nixpkgs;
    };
  };
}
