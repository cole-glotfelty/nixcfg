{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.features.cli.rclone;
  stateDir = "${config.xdg.stateHome}/rclone-bisync";

  # bisync refuses to run without a prior listing, so the first run per pair
  # must pass --resync. A marker file records that it has happened.
  mkSyncScript = name: sync:
    pkgs.writeShellScript "rclone-bisync-${name}" ''
      set -euo pipefail

      marker="${stateDir}/${name}.resynced"
      mkdir -p "${stateDir}" "${sync.localPath}"

      args=(
        bisync
        "${cfg.remote}:${sync.remotePath}"
        "${sync.localPath}"
        --create-empty-src-dirs
        --conflict-resolve "${sync.conflictResolve}"
        --conflict-loser num
        --resilient
        --recover
        --max-lock 2m
        --max-delete ${toString sync.maxDeletePercent}
        --transfers 8
        --checkers 16
        --log-level INFO
        ${optionalString sync.skipGoogleDocs "--drive-skip-gdocs"}
        ${escapeShellArgs sync.extraArgs}
      )

      if [ ! -e "$marker" ]; then
        echo "No prior bisync listing for '${name}' -- performing initial --resync."
        ${getExe pkgs.rclone} "''${args[@]}" --resync
        touch "$marker"
      else
        ${getExe pkgs.rclone} "''${args[@]}"
      fi
    '';

  syncOpts = { name, ... }: {
    options = {
      remotePath = mkOption {
        type = types.str;
        example = "Documents/Notes";
        description = ''
          Path within the remote, relative to its root. Empty string syncs the
          entire remote.
        '';
      };

      localPath = mkOption {
        type = types.str;
        example = "/home/pharo/GoogleDrive/Notes";
        description = "Absolute local directory to keep in sync. Created if missing.";
      };

      interval = mkOption {
        type = types.str;
        default = "15m";
        description = ''
          How often to sync, as a systemd time span. Also used as the delay
          after login before the first run.
        '';
      };

      conflictResolve = mkOption {
        type = types.enum [ "none" "newer" "older" "larger" "smaller" ];
        default = "newer";
        description = ''
          How to resolve a file changed on both sides since the last sync.
          The losing copy is kept alongside the winner with a numbered suffix,
          never deleted.
        '';
      };

      maxDeletePercent = mkOption {
        type = types.ints.between 0 100;
        default = 25;
        description = ''
          Abort the run if more than this percentage of files on either side
          would be deleted (bisync reads --max-delete as a percentage, unlike
          plain `rclone sync`). Guards against a half-mounted disk or an emptied
          remote wiping the other side.
        '';
      };

      skipGoogleDocs = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Skip native Google Docs/Sheets/Slides files. They have no real size
          or checksum, so bisync sees them as changed on every run. Turn this
          off only if you also set an export format in extraArgs.
        '';
      };

      extraArgs = mkOption {
        type = types.listOf types.str;
        default = [ ];
        example = [ "--exclude" "*.tmp" ];
        description = "Additional arguments appended to the rclone bisync invocation.";
      };
    };
  };
in
{
  options.features.cli.rclone = {
    enable = mkEnableOption (lib.mdDoc ''
      rclone with declarative two-way folder sync against a cloud remote.

      Features:
      - Installs rclone for interactive remote setup (`rclone config`)
      - Declares bidirectional syncs via `features.cli.rclone.syncs`
      - One systemd user service + timer per sync, with automatic first-run
        --resync and conflict/delete safeguards

      Note: credentials are NOT managed here. Run `rclone config` once to
      authorize the remote; the OAuth token lands in
      $XDG_CONFIG_HOME/rclone/rclone.conf.

      Linux only: the sync timers require systemd. On Darwin the package is
      still installed.
    '');

    remote = mkOption {
      type = types.str;
      default = "gdrive";
      description = ''
        Name of the configured rclone remote to sync against. Must match a
        remote created with `rclone config`.
      '';
    };

    syncs = mkOption {
      type = types.attrsOf (types.submodule syncOpts);
      default = { };
      example = literalExpression ''
        {
          notes = {
            remotePath = "Documents/Notes";
            localPath = "''${config.home.homeDirectory}/GoogleDrive/Notes";
            interval = "15m";
          };
        }
      '';
      description = "Folder pairs to keep bidirectionally in sync.";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    { home.packages = [ pkgs.rclone ]; }

    (mkIf pkgs.stdenv.isLinux {
      systemd.user.services = mapAttrs' (name: sync:
        nameValuePair "rclone-bisync-${name}" {
          Unit = {
            Description = "rclone bidirectional sync: ${cfg.remote}:${sync.remotePath}";
            After = [ "network-online.target" ];
            Wants = [ "network-online.target" ];
          };
          Service = {
            Type = "oneshot";
            ExecStart = "${mkSyncScript name sync}";
          };
        }) cfg.syncs;

      systemd.user.timers = mapAttrs' (name: sync:
        nameValuePair "rclone-bisync-${name}" {
          Unit.Description = "Periodic rclone bidirectional sync for ${name}";
          Timer = {
            OnStartupSec = sync.interval;
            OnUnitActiveSec = sync.interval;
            Persistent = true;
          };
          Install.WantedBy = [ "timers.target" ];
        }) cfg.syncs;
    })
  ]);
}
