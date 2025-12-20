{ config, lib, ... }:

with lib;
let cfg = config.features.cli.sshHosts;
in {
  options.features.cli.sshHosts.enable =
    mkEnableOption "enable sshHosts configuration";

  config = mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;

      matchBlocks = {
        halligan = {
          user = "cglotf01";
          hostname = "homework.cs.tufts.edu";
          identityFile = "${config.custom.user.homeDirectory}/.ssh/id_ed25519";
          serverAliveInterval = 15;
          port = 22;
        };

        vmprojw3 = {
          proxyJump = "halligan";
          user = "cglotf01";
          hostname = "vm-projectweb3";
          serverAliveInterval = 15;
        };
      };
    };
  };
}
