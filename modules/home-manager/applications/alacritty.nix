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
    programs.alacritty = let
      colors = config.features.style.colors.palette.dark;
    in {
      enable = true;
      settings = mkDefault {
        window = { opacity = 0.3; };
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
        colors = {
          primary = {
            background = "#${colors.bg}";
            foreground = "#${colors.fg}";
          };
          cursor = {
            text = "#${colors.bg}";
            cursor = "#${colors.fg}";
          };
          selection = {
            text = "#${colors.fg}";
            background = "#${colors.selection}";
          };
          normal = {
            black = "#${colors.black}";
            red = "#${colors.red}";
            green = "#${colors.green}";
            yellow = "#${colors.yellow}";
            blue = "#${colors.blue}";
            magenta = "#${colors.magenta}";
            cyan = "#${colors.cyan}";
            white = "#${colors.white}";
          };
          bright = {
            black = "#${colors.brightBlack}";
            red = "#${colors.red}";
            green = "#${colors.green}";
            yellow = "#${colors.yellow}";
            blue = "#${colors.blue}";
            magenta = "#${colors.magenta}";
            cyan = "#${colors.cyan}";
            white = "#${colors.brightWhite}";
          };
        };
      };
    };
  };
}
