{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.cli.latex;
in {
  options.features.cli.latex = {
    enable = mkEnableOption (lib.mdDoc ''
      LaTeX document typesetting with full TeX Live distribution.
      
      Features:
      - Complete TeX Live scheme-full package set
      - Support for all LaTeX packages and document classes
      - Academic paper, book, and presentation typesetting
      - Mathematical notation and scientific document support
      
      Package: texliveInfraOnly with scheme-full (comprehensive LaTeX installation)
      Integrates with: nixvim/vimtex plugin for LaTeX editing
    '');
  };

  config = mkIf cfg.enable {
    # This was painful to come to. Nix Docs suck for latex
    home.packages =
      [ (pkgs.texliveInfraOnly.withPackages (ps: with ps; [ scheme-full ])) ];
  };
}
