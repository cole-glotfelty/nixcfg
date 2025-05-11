{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.hardware.opengl;
in {
  options.features.hardware.opengl.enable =
    mkEnableOption "enable opengl";

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ ffmpeg-full libva vulkan-loader ];

    hardware.nvidia.modesetting.enable = true;

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };
  };
}
