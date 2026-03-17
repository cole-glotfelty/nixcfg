{ config, lib, ... }:

with lib;
let cfg = config.features.xdg.xdg_dirs;
in {
  options.features.xdg.xdg_dirs.enable = mkEnableOption (lib.mdDoc ''
    XDG user directory configuration with custom paths.

    Directory structure:
    - ~/Media/{Music,Videos,Pictures,Podcasts,Books,Games}
    - ~/Documents, ~/Downloads, ~/Templates
    - ~/Projects, ~/Remote
    - Disables Desktop and Public directories

    Creates directories automatically on activation
  '');

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
          REMOTE = "${config.home.homeDirectory}/Remote";
          PROJECTS = "${config.home.homeDirectory}/Projects";
          PODCAST = "${config.home.homeDirectory}/Media/Podcasts";
          BOOK = "${config.home.homeDirectory}/Media/Books";
          GAME = "${config.home.homeDirectory}/Media/Games";
          GAME_SAVE = "${config.home.homeDirectory}/Media/Game Saves";
        };
      };
    };
  };
}
