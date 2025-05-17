{ config, lib, pkgs, inputs, ... }:

with lib;
let sops = config.features.security.sops;
in {
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.pharo = mkMerge [
    {
      isNormalUser = true;

      description = "Cole Glotfelty";
      extraGroups = [
        "networkmanager"
        "wheel"
        "video"
        "audio"
        "input"
        "plugdev"
        "uinput"
        "kvm"
        "qemu-libvirtd"
        "libvirtd"
        "flatpak"
        "gamemode"
      ];
      packages = [ inputs.home-manager.packages.${pkgs.system}.default ];
    }

    # Conditionally set password if sops is setup
    (mkIf sops.enable {
      hashedPasswordFile = config.sops.secrets.pharo-passwd.path;
    })
  ];

  home-manager.users.pharo =
    import ../../../../home/linux/pharo/${config.networking.hostName}.nix;
}
