# HOST: Melchior
{ lib, ... }:

{
  imports = [
    ../common/linux
    ./configuration.nix
    ../features/apps
    ../features/hardware
    ../features/security
    ../features/wm
  ];

  features = {
    hardware = {
      bluetooth.enable = true;
      zenKernel.enable = true;
      QMKKeyboard.enable = true;
      opengl.enable = true;
      udisks2.enable = true;
      printing.enable = true;
      nvidia.enable = true;
    };

    security = {
      blocklist.enable = true;
      doas.enable = false; # This breaks devenv+standalone home-manager
      polkit.enable = true;
      sops.enable = true;
    };

    apps = {
      mullvad-vpn.enable = true;
      steam.enable = true;
      nixd.enable = true;
    };

    wm = {
      hyprland.enable = true;
      sound.enable = true;
      wayland.enable = true;
      fonts.enable = true;
      dbus.enable = true;
      fcitx5.enable = true;
      plymouth.enable = false; # Fix this so that from the boot loader it just gives loading screen
    };
  };
}
