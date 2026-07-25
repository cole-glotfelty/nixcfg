# Standalone nixvim VimTeX configuration
# Extracted from home/features/cli/nixvim/plugins/vimtex.nix

# vimtex.nix
# Note: Potentially working on occasion (still issues)

# <leader> ll : compile start/stop
# <leader> lk : stop compilation
# <leader> lc : clear auxiliary files a la `latexmk -C`
# <leader> li : view system commands executing compiler
# <leader> lo : inspect compiler output

{ pkgs, ... }:

{
  plugins.vimtex = {
    enable = true;
    settings = {
      compiler_method = "latexmk";
      latexmk_engines = { _ = "pdflatex"; };
      view_method = if pkgs.stdenv.isDarwin then "skim" else "zathura";
      viewer_options = if pkgs.stdenv.isDarwin then [] else [ "-sync" "-unique" ];
    };
  };
}