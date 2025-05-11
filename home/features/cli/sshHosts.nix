{ config, lib, ... }:

with lib;
let cfg = config.features.cli.sshHosts;
in {
  options.features.cli.sshHosts.enable =
    mkEnableOption "enable sshHosts configuration";

  config = mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      extraConfig = ''
        Host halligan
          User cglotf01
          HostName homework.cs.tufts.edu
          IdentityFile /home/pharo/.ssh/id_ed25519
          ServerAliveInterval 15
          Port 22

        Host vmprojw3
          ProxyJump halligan
          User cglotf01
          HostName vm-projectweb3
          ServerAliveInterval 15
      '';
    };
  };
}
