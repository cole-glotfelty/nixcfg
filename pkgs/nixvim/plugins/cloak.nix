# Standalone nixvim cloak configuration
# Extracted from home/features/cli/nixvim/plugins/cloak.nix
{ ... }:

{
  plugins.cloak = {
    enable = true;
    settings = {
      cloak_character = "*";
      enabled = true;
      highlight_group = "Comment";
      patterns = [{
        file_pattern = ".env*";
        cloak_pattern = "=.+";
      }];
    };
  };
}