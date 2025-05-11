{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.applications.kitty;
in {
  options.features.applications.kitty.enable =
    mkEnableOption "enable kitty application";
  config = mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      shellIntegration.mode = "no-cursor no-sudo";
      shellIntegration.enableZshIntegration = true;
      shellIntegration.enableBashIntegration = true;
      themeFile = "tokyo_night_night";

      font = {
        package = pkgs.nerd-fonts.fira-code;
        name = "FiraCode Nerd Font Mono";
      };

      settings = {
        cursor_shape = "block";
        cursor_blink_interval = 0;
        scrollback_lines = 10000;
        detect_urls = true;
      };
    };
  };
}
