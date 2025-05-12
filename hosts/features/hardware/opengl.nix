{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.hardware.opengl;
in {
  options.features.hardware.opengl.enable =
    mkEnableOption "enable opengl";

  config = mkIf cfg.enable {
# TODO: Lookinto these are they needed or already installed?
    environment.systemPackages = with pkgs; [ 
		ffmpeg-full
		vulkan-loader 
		libvdpau-va-gl
		libva-vdpau-driver
		libva
	];

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };
  };
}
