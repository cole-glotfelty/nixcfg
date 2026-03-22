{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.hardware.printing;
in {
  options.features.hardware.printing = {
    enable = mkEnableOption (lib.mdDoc ''
      CUPS printing system with network printer discovery.

      Features:
      - CUPS printing service for local and network printers
      - Avahi service discovery for automatic network printer detection
      - CUPS filters for enhanced printer compatibility
      - HP printer support via HPLIP drivers
      - Firewall configuration for network printing protocols

      Use case: Systems that need to print documents to local or network printers
      Dependencies: Physical printer hardware or network printer access
      Note: On macOS, printing is managed by system preferences
    '');
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = !pkgs.stdenv.isDarwin;
        message = ''
          Printing module is enabled but you're running on macOS.

          On macOS, printing is managed through System Preferences.
          This NixOS module will have no effect on Darwin systems.

          Consider disabling: features.hardware.printing.enable = false;
        '';
      }
    ];

    # Enable printing
    services.printing.enable = mkDefault true;

    # Printer drivers
    services.printing.drivers = mkDefault [ pkgs.hplip ];

    # Network printer discovery
    services.avahi = {
      enable = mkDefault true;
      nssmdns4 = mkDefault true;
      openFirewall = mkDefault true;
    };

    # Additional printer support
    environment.systemPackages = mkDefault [ pkgs.cups-filters pkgs.hplip ];
  };
}
