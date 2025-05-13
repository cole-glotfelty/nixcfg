{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.applications.media;
in {
  options.features.applications.media.enable =
    mkEnableOption "enable media applications";
  config = mkIf cfg.enable {
    # TODO: Come back, bc some of thesse may require themeing or the such
    home.packages = with pkgs; [
      foliate # epub reader
      zathura # pdf viewer
      feh # image viewer
      transmission_4-gtk # torrent client
      cmus # music player # NOTE: potenitally replace with MPD and Client
      yt-dlp # webvideo downloading
      # TODO: fix plex desktop being borked
      # plex-desktop # personal streamed media
      # plexamp
      # cider # apple music client (electron bleh)
    ];

    programs.mpv = {
      enable = true;
      config = { hwdec = "auto"; };
    };
  };
}
