{ config, pkgs, inputs, ... }:

{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.pharo = {
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
    ];
    packages = [ inputs.home-manager.packages.${pkgs.system}.default ];
  };
  home-manager.users.pharo =
    import ../../../../home/linux/pharo/${config.networking.hostName}.nix;
}
