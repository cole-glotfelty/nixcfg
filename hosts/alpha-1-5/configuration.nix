{ self, inputs, outputs, pkgs, ... }:

{
  imports = [ ../common/darwin/users/coleglotfelty.nix ];
  # Necessary for using flakes on this system.
  nix.settings = {
    experimental-features = "nix-command flakes";
    trusted-users = [ "root" "coleglotfelty" ];
  };

  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.stable-packages
    ];
    config = { allowUnfree = true; };
  };

  # Auto upgrade nix package and the daemon service
  nix.enable = true;

  # Set Hostname
  networking.hostName = "alpha-1-5";

  # Enable alternative shell support in nix-darwin.
  programs.zsh.enable = true;

  environment.systemPackages = with pkgs; [ vim git nixd just ];

  # Set Git commit hash for darwin-version.
  system.configurationRevision = self.rev or self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
}
