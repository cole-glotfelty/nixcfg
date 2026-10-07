# HOST: Melchior
{ lib, ... }:

rec {
  # Metadata for flake auto-generation
  _meta = {
    system = "nixos";
    architecture = "x86_64-linux";
    users = [ "pharo" ];
  };

  imports = [
    (../../modules/common + "/${_meta.system}")
    ./configuration.nix
    ../../modules/nixos/apps
    ../../modules/nixos/hardware
    ../../modules/nixos/security
    ../../modules/nixos/wm
  ];

  features = {
    hardware = {
      bluetooth.enable = true;
      zenKernel.enable = true;
      QMKKeyboard.enable = true;
      opengl.enable = true;
      udisks2.enable = true;
      printing.enable = true;
      nvidia = {
        enable = true;
        # GTX 1080 (Pascal). Needed for pkgs.ollama-cuda to actually build
        # GPU-targeted code for this card instead of silently falling back
        # to CPU-only inference.
        cudaCapabilities = [ "6.1" ];
      };
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
      tailscale.enable = true;
      ollama.enable = true;
      rclone-webdav = {
        enable = true;
        path = "/home/pharo/Documents/Obsidian";
      };
    };

    wm = {
      sound.enable = true;
      wayland.enable = true;
      fonts.enable = true;
      dbus.enable = true;
      fcitx5.enable = true;
      plymouth.enable = false; # Fix this so that from the boot loader it just gives loading screen
    };
  };
}
