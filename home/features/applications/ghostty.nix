{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.applications.ghostty;
in {
  options.features.applications.ghostty.enable =
    mkEnableOption "enable ghostty application";
  config = mkIf cfg.enable {
    home.packages = with pkgs; [ nerd-fonts.fira-code ];

    programs.ghostty = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;

      settings = {
        shell-integration-features = "no-cursor, no-sudo";
        cursor-style-blink = false;
        cursor-style = "block";

        font-family = "FiraCode Nerd Font Mono";
        font-size = 11;

        # TODO: Change around padding to match kitty
        # TODO: Change this to auto update w/ nix-colors
        theme = "tokyonight_night";
      };
    };
  };
}
