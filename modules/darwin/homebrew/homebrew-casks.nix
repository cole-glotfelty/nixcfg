{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.homebrew.casks;
in {
  options.features.homebrew.casks.enable = mkEnableOption (lib.mdDoc ''
    Homebrew Cask applications for macOS GUI apps.

    Included apps:
    - Media: Audacity, OBS, Blender, GIMP, XLD, MakeMKV, MPV
    - Productivity: DrawIO, Numi, Picard
    - Communication: Signal, Telegram
    - Utilities: Mullvad VPN, Transmission, Tor Browser
    - Games: SuperTuxKart
    - System: UTM, XQuartz, Raspberry Pi Imager

    Dependencies: features.homebrew.enable
  '');

  config = mkIf cfg.enable {
    homebrew = {
      enable = true;
      casks = [
        "audacity"
        "blender"
        "drawio"
        "makemkv"
        "mpv"
        "mullvad-vpn"
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
