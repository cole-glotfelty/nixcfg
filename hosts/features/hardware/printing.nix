{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.hardware.printing;
in {
  options.features.hardware.printing.enable =
    mkEnableOption "enable printing";

  config = mkIf cfg.enable {
    # Enable printing
    services.printing.enable = true;

    # Related to printing
    services.avahi.enable = true;
    services.avahi.nssmdns4 = true;
    services.avahi.openFirewall = true;
    environment.systemPackages = [ pkgs.cups-filters ];
  };
}
