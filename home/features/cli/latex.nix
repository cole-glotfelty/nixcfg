{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.cli.latex;
in {
  options.features.cli.latex.enable = mkEnableOption "enable latex compilation";

  config = mkIf cfg.enable {
    # This was painful to come to. Nix Docs suck for latex
    home.packages =
      [ (pkgs.texliveInfraOnly.withPackages (ps: with ps; [ scheme-full ])) ];
  };
}
