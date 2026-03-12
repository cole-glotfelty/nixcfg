{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.features.applications.mpd;
  home = config.home.homeDirectory;
  musicDir =
    if pkgs.stdenv.isDarwin
    then "${home}/Music"
    else "${home}/Media/Music";
in {
  options.features.applications.mpd = {
    enable = mkEnableOption (lib.mdDoc ''
      MPD (Music Player Daemon) with a terminal client.

      Includes:
      - MPD: Background music daemon for managing and playing music
      - rmpc: Modern terminal MPD client

      Use case: Local music library management and playback
      Alternative to: cmus, spotify, rhythmbox
    '');
  };

  config = mkIf cfg.enable {
    services.mpd = mkIf (!pkgs.stdenv.isDarwin) {
      enable = true;
      musicDirectory = musicDir;
      extraConfig = ''
        bind_to_address "localhost"

        audio_output {
          type "pipewire"
          name "PipeWire"
        }
      '';
    };

    home.packages = mkIf pkgs.stdenv.isDarwin [ pkgs.mpd ];

    xdg.configFile."mpd/mpd.conf" = mkIf pkgs.stdenv.isDarwin {
      text = ''
        music_directory     "${musicDir}"
        db_file             "${home}/.local/share/mpd/mpd.db"
        playlist_directory  "${home}/.local/share/mpd/playlists"
        log_file            "${home}/.local/share/mpd/mpd.log"
        pid_file            "${home}/.local/share/mpd/mpd.pid"
        state_file          "${home}/.local/share/mpd/mpdstate"
        bind_to_address     "localhost"

        audio_output {
          type "osx"
          name "CoreAudio"
        }
      '';
    };

    launchd.agents.mpd = mkIf pkgs.stdenv.isDarwin {
      enable = true;
      config = {
        ProgramArguments = [
          "${pkgs.mpd}/bin/mpd"
          "--no-daemon"
          "${config.xdg.configHome}/mpd/mpd.conf"
        ];
        KeepAlive = true;
        RunAtLoad = true;
      };
    };

    programs.rmpc = {
      enable = true;
    };
  };
}
