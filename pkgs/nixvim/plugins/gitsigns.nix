# Standalone nixvim gitsigns configuration
# Extracted from home/features/cli/nixvim/plugins/gitsigns.nix
{ ... }:

{
  plugins.gitsigns = {
    enable = true;
    settings = {
      numhl = false;
      linehl = false;
      signs = {
        add = { text = "▎"; };
        change = { text = "▎"; };
        delete = { text = "_"; };
        topdelete = { text = "‾"; };
        changedelete = { text = "▎"; };
      };
    };
  };
}