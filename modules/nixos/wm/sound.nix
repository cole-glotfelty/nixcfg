{ config, lib, ... }:

with lib;
let cfg = config.features.wm.sound;
in {
  options.features.wm.sound = {
    enable = mkEnableOption (lib.mdDoc ''
      Modern audio system using PipeWire with low-latency support.
      
      Features:
      - PipeWire audio server for professional-grade audio handling
      - PulseAudio compatibility layer for existing applications
      - ALSA support with 32-bit compatibility for gaming
      - JACK support for professional audio applications
      - Real-time scheduling for low-latency audio
      
      Use case: Desktop systems requiring audio playback and recording
      Dependencies: Audio hardware, desktop applications
      Replaces: PulseAudio with modern, lower-latency alternative
    '');
  };

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
