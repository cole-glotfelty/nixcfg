{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.wm.plymouth;
in {
  options.features.wm.plymouth.enable = mkEnableOption "enable plymouth";

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
