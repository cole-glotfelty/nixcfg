{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.cli.abcde;
in {
  options.features.cli.abcde = {
    enable = mkEnableOption (lib.mdDoc ''
      ABCDE (A Better CD Encoder) for ripping and encoding audio CDs.
      
      Features:
      - Command-line CD ripping and encoding tool
      - Support for multiple audio formats (FLAC, MP3, OGG, etc.)
      - Automatic metadata retrieval from CDDB/MusicBrainz
      - Batch processing for entire CD collections
      
      Use case: Converting physical CDs to digital audio files
      Package: abcde
    '');
  };

  config = mkIf cfg.enable { home.packages = with pkgs; [ abcde ]; };
}
