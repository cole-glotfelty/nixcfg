# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ inputs, pkgs, lib, config, ... }:

let
  # pkgs-hyprland =
  #   inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in {
  imports = [ ./hardware-configuration.nix ./disk-config.nix ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable Networking
  networking.hostName = "melchior";
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ]; # Cloudflare/Google
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Chicago";
  services.timesyncd.enable = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [ vim git nixd just ];

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";
    allowSFTP = true;
  };

  # ZSH Default Shell
  programs.zsh.enable = true;
  environment.shells = with pkgs; [ zsh bash dash ];
  # users.defaultUserShell = pkgs.zsh;

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    configPackages =
      [ pkgs.xdg-desktop-portal-hyprland pkgs.xdg-desktop-portal-gtk ];
  };
  # zenKernel (7.2.9) outpaced the pinned nixpkgs' legacy_580 build
  # (580.173.02, still needed since Pascal was dropped from the stable
  # driver at 595.x+): NVIDIA's own os-interface.c called the kernel's
  # strncpy(), which 7.2.9 removed. nixpkgs-unstable already carries
  # NVIDIA's 580.178.04, which fixed this upstream (switched to
  # strscpy()) against the identical 7.2.9 kernel, so pull both the
  # kernel and the matching driver from that scope to keep them
  # ABI-matched instead of patching the driver source ourselves.
  #
  # TODO: revert both lines back to the plain `pkgs.linuxPackages_zen` /
  # `config.boot.kernelPackages.nvidiaPackages.legacy_580` once a future
  # `nix flake update` brings the pinned (stable) nixpkgs' legacy_580 up
  # to >= 580.178.04 (or nixpkgs otherwise patches this).
  boot.kernelPackages = lib.mkForce pkgs.unstable.linuxPackages_zen;
  hardware.nvidia.package =
    pkgs.unstable.linuxPackages_zen.nvidiaPackages.legacy_580;

  system.stateVersion = "24.11"; # Did you read the comment? DO NOT CHANGE
}
