{ config, lib, ... }:

with lib;
let cfg = config.features.cli.nixvim;
in {
  config = mkIf cfg.enable {
    programs.nixvim.plugins = {
      cloak = {
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
    };
  };
}
