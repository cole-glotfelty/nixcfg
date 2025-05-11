{ config, lib, ... }:

with lib;
let cfg = config.features.wm.sound;
in {
  options.features.wm.sound.enable = mkEnableOption "enable sound via pipewire";

  config = mkIf cfg.enable {
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

  };
}
