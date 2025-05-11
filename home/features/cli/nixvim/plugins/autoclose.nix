{ config, lib, ... }:

with lib;
let cfg = config.features.cli.nixvim;
in {
  config = mkIf cfg.enable {
    # TODO: See if this other plugin works better
    # TODO: see if it can detect over lines
    programs.nixvim = {
      # plugins.autoclose = {
      #   enable = true;
      #   settings = {
      #     options = {
      #       disabledFiletypes = [ "text" "markdown" "TelescopePrompt" ];
      #       disableWhenTouch = true;
      #       disableCommandMode = true;
      #     };
      #   };
      # };
      plugins.nvim-autopairs = {
        enable = true;
        settings = {
          disable_filetype = [ "text" "markdown" "TelescopePrompt" ];
        };
      };
    };
  };
}
