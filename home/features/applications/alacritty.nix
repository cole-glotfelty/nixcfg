{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.applications.alacritty;
in {
  options.features.applications.alacritty.enable =
    mkEnableOption "enable alacritty application";
  config = mkIf cfg.enable {
    # TODO: Put dependency to install Fira Code Nerd Font
    programs.alacritty = {
      enable = true;
      settings = {
        window = { opacity = 1; };
        cursor = { unfocused_hollow = true; };
        font = {
          size = 12;
          normal = {
            family = "FiraCode Nerd Font Mono";
            style = "Regular";
          };
          bold = {
            family = "FiraCode Nerd Font Mono";
            style = "Bold";
          };
          italic = {
            family = "FiraCode Nerd Font Mono";
            style = "Italic";
          };
          bold_italic = {
            family = "FiraCode Nerd Font Mono";
            style = "Bold Italic";
          };
        };
      };
    };
  };
}
