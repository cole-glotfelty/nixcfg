# HOST: Casper
{ lib, pkgs, ... }:

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
    };

    security = {
      blocklist.enable = true;
      doas.enable = false;
      polkit.enable = true;
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
    };
  };

  # Note on extra packages:
  # it's GPU specific this is for intel iGPU
  # TODO: Potenitally make this only enable if opengl feature is active
  # OR attach this to a specialization
  # (example) https://code.m3tam3re.com/m3tam3re/nixos-config/src/commit/39e11879486183522a9ecb5cdb44d7c96db508ee/home/m3tam3re/m3-kratos.nix
  hardware.graphics.extraPackages = with pkgs; [
    intel-compute-runtime
    intel-media-driver
    intel-vaapi-driver
    mesa
  ];
}
