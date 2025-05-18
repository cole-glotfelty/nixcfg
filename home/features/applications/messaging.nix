{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.applications.messaging;
in {
  options.features.applications.messaging.enable =
    mkEnableOption "enable messaging applications";
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # Text/Voice
      discord
      slack
      signal-desktop

      # Video Calling
      zoom-us

      # Email
      thunderbird
    ];

    # Email
    # programs.thunderbird = {
    #   enable = true;
    # };
  };
}
