{ config, lib, ... }:

with lib;
let cfg = config.features.xdg.xdg_dirs;
in {
  options.features.xdg.xdg_dirs.enable =
    mkEnableOption "enable xdg_dirs configuration";

  config = mkIf cfg.enable {
    xdg = {
      userDirs = {
        enable = true;
        createDirectories = true;
        music = "${config.home.homeDirectory}/Media/Music";
        videos = "${config.home.homeDirectory}/Media/Videos";
        pictures = "${config.home.homeDirectory}/Media/Pictures";
        templates = "${config.home.homeDirectory}/Templates";
        download = "${config.home.homeDirectory}/Downloads";
        documents = "${config.home.homeDirectory}/Documents";
        desktop = null;
        publicShare = null;
        extraConfig = {
          XDG_REMOTE_DIR = "${config.home.homeDirectory}/Remote";
          XDG_PROJECTS_DIR = "${config.home.homeDirectory}/Projects";
          XDG_PODCAST_DIR = "${config.home.homeDirectory}/Media/Podcasts";
          XDG_BOOK_DIR = "${config.home.homeDirectory}/Media/Books";
          XDG_GAME_DIR = "${config.home.homeDirectory}/Media/Games";
          XDG_GAME_SAVE_DIR = "${config.home.homeDirectory}/Media/Game Saves";
        };
      };
    };
  };
}
