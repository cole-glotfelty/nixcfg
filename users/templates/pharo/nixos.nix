{ config, lib, pkgs, inputs, ... }:

with lib;
let
  sops = config.features.security.sops;
  hostName = config.networking.hostName;
  userConfigPath = ../../../hosts/${hostName}/users/pharo.nix;
  userConfigExists = builtins.pathExists userConfigPath;
in mkIf userConfigExists {
  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.pharo = mkMerge [
    {
      isNormalUser = true;

      description = "Cole Glotfelty";
      extraGroups = [
        "networkmanager" # Manage network connections (WiFi, Ethernet, VPN)
        "wheel" # Administrative privileges (sudo/root access)
        "video" # Access to graphics cards, cameras, hardware video acceleration
        "audio" # Access to audio devices and sound system
        "input" # Access to keyboards, mice, touchpads, game controllers
        "plugdev" # Access to removable/pluggable devices (USB drives, external storage)
        "uinput" # Create virtual input devices (input remapping, accessibility tools)
        "kvm" # Kernel-based virtual machine hardware acceleration
        "qemu-libvirtd" # QEMU virtualization through libvirt management
        "libvirtd" # General libvirt virtualization management daemon
        "flatpak" # Install and manage Flatpak applications without root
        "gamemode" # Feral GameMode CPU/GPU performance optimizations for gaming
      ];
      packages = [ inputs.home-manager.packages.${pkgs.system}.default ];
    }

    # Conditionally set password if sops is setup
    (mkIf sops.enable {
      hashedPasswordFile = config.sops.secrets.pharo-passwd.path;
    })
  ];

  home-manager.users.pharo = {
    imports = [
      ./.
    ] ++ lib.optionals userConfigExists [
      userConfigPath
    ];
  };
}
