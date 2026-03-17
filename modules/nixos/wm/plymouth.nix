{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.wm.plymouth;
in {
  options.features.wm.plymouth.enable = mkEnableOption (lib.mdDoc ''
    Plymouth boot splash screen with silent boot configuration.

    Features:
    - Animated "rings" theme from adi1090x-plymouth-themes
    - Silent boot with suppressed kernel messages
    - Clean graphical boot experience

    Note: Replaces verbose text output during system startup
  '');

  config = mkIf cfg.enable {
    boot = {
      plymouth = {
        enable = true;
        theme = "rings";
        themePackages = with pkgs;
          [
            # By default we would install all themes
            (adi1090x-plymouth-themes.override {
              selected_themes = [ "rings" ];
            })
          ];
      };

      # Enable "Silent boot"
      consoleLogLevel = 3;
      initrd.verbose = false;
      kernelParams = [
        "quiet"
        "splash"
        "boot.shell_on_fail"
        "udev.log_priority=3"
        "rd.systemd.show_status=auto"
      ];
    };
  };
}
