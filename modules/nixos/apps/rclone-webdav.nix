{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.apps.rclone-webdav;
in {
  options.features.apps.rclone-webdav = {
    enable = mkEnableOption (lib.mdDoc ''
      Local WebDAV server (via `rclone serve webdav`) exposing a directory
      for sync clients such as the Obsidian "Remotely Save" plugin.

      Features:
      - Systemd system service running `rclone serve webdav`
      - Bound to localhost only; pair with features.apps.tailscale and
        `tailscale serve` for remote access without exposing it publicly
      - Auth via an htpasswd file sourced from a sops secret

      Dependencies: features.security.sops must be enabled, and a secret
      named by `htpasswdSecret` must exist in secrets.yaml, containing the
      contents of an htpasswd file (e.g. output of `htpasswd -nB <user>`).
    '');

    path = mkOption {
      type = types.str;
      example = "/home/pharo/Documents/Obsidian/Mother Vault";
      description = "Absolute local directory to serve over WebDAV. Created if missing.";
    };

    port = mkOption {
      type = types.port;
      default = 8093;
      description = "Port to bind the WebDAV server to on localhost.";
    };

    user = mkOption {
      type = types.str;
      default = "pharo";
      description = "User to run the service as, and owner of the decrypted htpasswd secret.";
    };

    htpasswdSecret = mkOption {
      type = types.str;
      default = "webdav-htpasswd";
      description = "Name of the sops secret containing the htpasswd file contents.";
    };
  };

  config = mkIf cfg.enable {
    sops.secrets.${cfg.htpasswdSecret} = {
      owner = cfg.user;
      restartUnits = [ "rclone-webdav.service" ];
    };

    systemd.services.rclone-webdav = {
      description = "rclone WebDAV server for ${cfg.path}";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${escapeShellArg cfg.path}";
        ExecStart = ''
          ${getExe pkgs.rclone} serve webdav ${escapeShellArg cfg.path} \
            --addr 127.0.0.1:${toString cfg.port} \
            --htpasswd ${config.sops.secrets.${cfg.htpasswdSecret}.path}
        '';
        Restart = "on-failure";
      };
    };
  };
}
