{ config, lib, ... }:

with lib;
let cfg = config.features.desktop.defaultFonts;
in {
  options.features.desktop.defaultFonts.enable =
    mkEnableOption "enable defaultFonts";

  config = mkIf cfg.enable {
    fonts.fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [ "Times New Roman" "Noto Serif" "Liberation Serif" ];
        # TODO: Look into Nimbus Sans for sansSerif
        sansSerif = [ "Noto Sans" "Liberation Sans" ];
        monospace = [ "FiraCode Nerd Font Mono" "Liberation Mono" ];
        # TODO: Look into Apple Emoji font for system emoji font
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}
