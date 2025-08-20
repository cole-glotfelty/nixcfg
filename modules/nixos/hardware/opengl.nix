{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.hardware.opengl;
in {
  options.features.hardware.opengl = {
    enable = mkEnableOption (lib.mdDoc ''
      OpenGL and hardware graphics acceleration support.
      
      Features:
      - Hardware graphics acceleration (OpenGL/Vulkan)
      - 32-bit graphics support for compatibility
      - Video acceleration libraries (VDPAU/VAAPI)
      - Graphics debugging and inspection tools
      - FFmpeg with full codec support
      
      Use case: Systems requiring 3D graphics, video acceleration, or gaming
      Dependencies: GPU hardware (integrated or discrete)
      Integrates with: NVIDIA/Intel/AMD graphics modules
    '');
  };

  config = mkIf cfg.enable {
    # TODO: Lookinto these are they needed or already installed?
    environment.systemPackages = mkDefault (with pkgs; [
      ffmpeg-full
      vulkan-loader
      vulkan-tools
    ]);

    hardware.graphics.extraPackages = mkDefault (with pkgs; [
      libvdpau-va-gl
      libva-vdpau-driver
      libva-utils
      vdpauinfo
      libva
    ]);

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };
  };
}
