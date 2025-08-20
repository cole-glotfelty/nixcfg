{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.applications.media;
in {
  options.features.applications.media = {
    enable = mkEnableOption (lib.mdDoc ''
      Comprehensive media consumption and management applications.
      
      Includes:
      - MPV: Video player with hardware decoding
      - Foliate: EPUB reader for books
      - Zathura: Minimal PDF viewer
      - Feh: Lightweight image viewer
      - Transmission: BitTorrent client with GTK interface
      - CMUS: Terminal-based music player
      - yt-dlp: YouTube and web video downloader
      
      Use case: Complete media toolkit for reading, viewing, and downloading content
      Alternative to: VLC, Adobe Reader, specialized media applications
    '');
  };
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
