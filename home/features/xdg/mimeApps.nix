{ config, lib, ... }:

with lib;
let cfg = config.features.xdg.mimeApps;
in {
  options.features.xdg.mimeApps.enable =
    mkEnableOption "enable mimeApps configuration";

  config = mkIf cfg.enable {
    xdg = {
      mimeApps = {
        enable = true;
        # TODO: Come back and replace some with values from variables .editor, .browser
        defaultApplications = {
          "text/plain" = [ "nvim.desktop" ];
          "text/*" = [ "nvim.desktop" ];
          "image/*" = [ "feh.desktop" ];
          "video/*" = [ "mpv.desktop" ];
          "application/pdf" = [ "zathura.desktop" ];
          "x-scheme-handler/https" = [ "librewolf.desktop" ]; # Links
          "x-scheme-handler/http" = [ "librewolf.desktop" ]; # Links
          "x-scheme-handler/discord" = [ "discord.desktop" ];
          #"x-scheme-handler/mailto" = ["firefox.desktop"]; # Email
        };
      };
    };
  };
}
