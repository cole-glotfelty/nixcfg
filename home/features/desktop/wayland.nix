{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.desktop.wayland;
in {
  options.features.desktop.wayland.enable =
    mkEnableOption "wayland extra tools and config";

  config = mkIf cfg.enable {
    # NOTE: All commented out packages deserve to be researched at a later date
    home.packages = with pkgs; [
      grim
      slurp
      qt6.qtwayland
      # waypipe
      # wf-recorder
      # wl-mirror
      wl-clipboard
      wlogout
      # wtype
      # ydotool
    ];
  };
}
