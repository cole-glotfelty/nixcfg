{ config, lib, ... }:

with lib;
let cfg = config.features.cli.sshHosts;
in {
  options.features.cli.sshHosts.enable = mkEnableOption (lib.mdDoc ''
    SSH client configuration with predefined host aliases.

    Configured hosts:
    - halligan: Tufts CS homework server
    - vmprojw3: Project VM via halligan proxy jump

    Uses Ed25519 identity key from ~/.ssh/
  '');

  config = mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;

      settings = {
        "halligan" = {
          User = "cglotf01";
          HostName = "homework.cs.tufts.edu";
          IdentityFile = "${config.custom.user.homeDirectory}/.ssh/id_ed25519";
          ServerAliveInterval = 15;
          Port = 22;
        };

        "vmprojw3" = {
          ProxyJump = "halligan";
          User = "cglotf01";
          HostName = "vm-projectweb3";
          ServerAliveInterval = 15;
        };
      };
    };
  };
}
