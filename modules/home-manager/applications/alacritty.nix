{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.applications.alacritty;
in {
  options.features.applications.alacritty.enable = mkEnableOption (lib.mdDoc ''
    Alacritty GPU-accelerated terminal emulator.

    Configuration:
    - FiraCode Nerd Font Mono at size 12
    - 80% window opacity
    - Unfocused hollow cursor

    Alternative to: Kitty, Ghostty
  '');
  config = mkIf cfg.enable {
    home.packages = with pkgs; [ nerd-fonts.fira-code ];
    programs.alacritty = {
      enable = true;
      settings = {
        window = { opacity = 0.8; };
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
