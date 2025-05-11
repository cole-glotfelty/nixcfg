{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.homebrew.casks;
in {
  options.features.homebrew.casks.enable =
    mkEnableOption "enable homebrew casks";

  config = mkIf cfg.enable {
    homebrew = {
      enable = true;
      casks = [
        "claude"
        "audacity"
        "blender"
        "drawio"
        "makemkv"
        "mullvadvpn"
        "museeks"
        "musicbrainz-picard"
        "numi"
        "obs"
        "raspberry-pi-imager"
        "signal"
        "telegram"
        "supertuxkart"
        "transmission"
        "tor-browser"
        "utm"
        "xld"
        "xquartz"
        "gimp"
        "rockboxutility"
      ];
    };
  };
}
