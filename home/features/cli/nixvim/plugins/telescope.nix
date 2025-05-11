{ config, lib, ... }:

with lib;
let cfg = config.features.cli.nixvim;
in {
  config = mkIf cfg.enable {
    programs.nixvim.plugins = {
      telescope = {
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
    };
  };
}
