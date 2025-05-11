{ config, lib, ... }:

with lib;
let cfg = config.features.cli.nixvim;
in {
  config = mkIf cfg.enable {
    programs.nixvim = {
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
    };
  };
}
