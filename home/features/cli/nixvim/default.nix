{ config, lib, inputs, outputs, pkgs, ... }:

with lib;
let cfg = config.features.cli.nixvim;
in {
  imports = [
    inputs.nixvim.homeModules.nixvim
  ];

  options.features.cli.nixvim.enable =
    mkEnableOption "enable nixvim configuration";

  config = mkIf cfg.enable {
    programs.vim.enable = mkForce false;
    programs.nixvim = outputs.packages.${pkgs.system}.nixvim.passthru.config // {
      enable = true;
      # Home-manager specific settings that aren't in standalone
      vimdiffAlias = true; # this could cause problems
    };
  };
}
