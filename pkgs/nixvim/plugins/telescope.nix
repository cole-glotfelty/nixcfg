# Standalone nixvim telescope configuration
# Extracted from home/features/cli/nixvim/plugins/telescope.nix
{ ... }:

{
  plugins.telescope = {
    enable = true;
    keymaps = {
      "<leader>ff" = "find_files";
      "<leader>fg" = "live_grep";
      "<leader>ps" = "project";
    };
    extensions = {
      fzf-native.enable = true;
      frecency.enable = true;
      media-files.enable = true;
      project.enable = true;
    };
    luaConfig.pre = ''
      defaults = {
      file_ignore_patterns = {".git/"},
      }
    '';
  };
}