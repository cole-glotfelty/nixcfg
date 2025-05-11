{ config, lib, ... }:

with lib;
let cfg = config.features.cli.ranger;
in {
  options.features.cli.ranger.enable =
    mkEnableOption "enable ranger configuration";

  config = mkIf cfg.enable {
    programs.ranger = {
      enable = true;
      settings = {
        preview_images = true;
        # TODO: Figure out if there's a way to make this work with alacritty and kitty
        preview_images_method = "kitty";
      };
    };
  };
}
