# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, pkgs, ... }:

let
  pkgs-hyprland =
    inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in {
  imports = [ ./hardware-configuration.nix ];

  # Maybe fixes youtube/firefox's weirdness
  boot.kernelParams = [ "intel_pstate=active" "vm.swappiness=10" ];
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 25;
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable Networking
  networking.hostName = "casper";
  networking.nameservers = [ "1.1.1.1" "8.8.8.8"]; # Cloudflare/Google
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

  # Change /bin/(ba)sh to /bin/dash
  # TODO: Determine if this should be here (or in default or in common)
  # TODO: Check if this is causing issues on startup
  environment.binsh = "${pkgs.dash}/bin/dash";

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    configPackages =
      [ pkgs-hyprland.xdg-desktop-portal-hyprland pkgs.xdg-desktop-portal-gtk ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
