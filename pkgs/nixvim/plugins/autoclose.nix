# Standalone nixvim autoclose configuration
# Extracted from home/features/cli/nixvim/plugins/autoclose.nix

# TODO: See if this other plugin works better
# TODO: see if it can detect over lines

{ ... }:

{
  plugins.nvim-autopairs = {
    enable = true;
    settings = {
      disable_filetype = [ "text" "markdown" "TelescopePrompt" ];
    };
  };
}