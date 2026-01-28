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
        defaultApplications = {
          "text/plain" = mkDefault [ "${config.custom.defaults.editor}.desktop" ];
          "text/*" = mkDefault [ "${config.custom.defaults.editor}.desktop" ];
          "image/*" = mkDefault [ "feh.desktop" ];
          "video/*" = mkDefault [ "mpv.desktop" ];
          "application/pdf" = mkDefault [ "zathura.desktop" ];
          "x-scheme-handler/discord" = mkDefault [ "discord.desktop" ];
        }
        // optionalAttrs (config.custom.defaults.browser != "") {
          "x-scheme-handler/https" = mkDefault [ "${config.custom.defaults.browser}.desktop" ]; # Links
          "x-scheme-handler/http" = mkDefault [ "${config.custom.defaults.browser}.desktop" ]; # Links
        }
        // optionalAttrs (config.custom.defaults.mailClient != "") {
          "x-scheme-handler/mailto" = mkDefault [ "${config.custom.defaults.mailClient}.desktop" ]; # Email
        };
      };
    };
  };
}
