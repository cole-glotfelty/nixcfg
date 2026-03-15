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
      # Cross-platform packages
      yt-dlp # webvideo downloading
      # TODO: fix plex desktop being borked
      # plex-desktop # personal streamed media
      # plexamp
      # cider # apple music client (electron bleh)
    ] ++ lib.optionals stdenv.isLinux [
      # Linux-specific packages
      foliate # epub reader
      zathura # pdf viewer  
      feh # image viewer
      transmission_4-gtk # torrent client
    ];

    programs.mpv = {
      enable = true;
      config = {
        # Hardware acceleration
        hwdec = "auto";
        # Video output - use gpu for better compatibility on macOS
        vo = "gpu";
        # GPU API - Use vulkan on macOS (metal not available in this build)
        gpu-api = if pkgs.stdenv.isDarwin then "vulkan" else "auto";
        # Better seeking and playback
        hr-seek = "yes";
        # Window settings
        geometry = "50%:50%";
        autofit-larger = "90%x90%";
        # Subtitle settings
        sub-auto = "fuzzy";
        # Cache settings
        cache = "yes";
        demuxer-max-bytes = "512MiB";
      } // lib.optionalAttrs pkgs.stdenv.isDarwin {
        # Audio output - only set on macOS; Linux uses built-in auto-detection
        ao = "coreaudio";
      };
    };
  };
}
