# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ inputs, pkgs, ... }:

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
  time.timeZone = "America/New_York";
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
  environment.systemPackages = with pkgs; [ vim git nixd just sops ];

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";
    allowSFTP = true;
  };

  # ZSH Default Shell
  programs.zsh.enable = true;
  environment.shells = with pkgs; [ zsh bash dash ];
  # users.defaultUserShell = pkgs.zsh;

  # Change /bin/(ba)sh to /bin/dash
  # TODO: Determine if this should be here (or in default or in common)
  # TODO: Check if this is causing issues on startup
  environment.binsh = "${pkgs.dash}/bin/dash";

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    configPackages =
      [ pkgs.xdg-desktop-portal-hyprland pkgs.xdg-desktop-portal-gtk ];
  };
  system.stateVersion = "24.11"; # Did you read the comment? DO NOT CHANGE
}
