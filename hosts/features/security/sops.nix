{ inputs, config, lib, pkgs, ... }:

with lib;
let cfg = config.features.security.sops;
in {

  # imports = [ inputs.sops-nix.nixosModule.sops ];

  options.features.security.sops.enable = mkEnableOption "enable sops";

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ sops ];

    # required for password to be set via sops during system activation
    users.mutableUsers = false;

    sops = {
      defaultSopsFile = ../../../secrets.yaml;
      validateSopsFiles = false;

      # Decrypt password so user can be made
      secrets.pharo-passwd.neededForUsers = true;

      age = {
        # Automatically import host SSH keys as age keys
        sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
        # Use an age key already in the file system
        keyFile = "/var/lib/sops-nix/key.txt";
        # If above location doesn't have a key, generate one
        generateKey = true;
      };
    };
  };
}
