{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.hardware.nvidia;
in {
  options.features.hardware.nvidia = {
    enable = mkEnableOption (lib.mdDoc ''
      NVIDIA GPU support with proprietary drivers and hardware acceleration.
      
      Features:
      - NVIDIA proprietary drivers (stable version)
      - Hardware-accelerated video decoding (VAAPI)
      - NVIDIA Settings GUI for configuration
      - Modesetting support for Wayland compatibility
      - Optimized for hybrid Intel + NVIDIA setups
      
      Use case: Systems with NVIDIA discrete graphics cards
      Dependencies: NVIDIA GPU hardware
      Note: Linux only - has no effect on macOS
    '');
  };

  config = mkIf cfg.enable {
	services.xserver.videoDrivers = mkDefault [ "nvidia" ];

    # Note on extra packages:
    # it's GPU specific this is for intel iGPU
    # TODO: Potenitally make this only enable if opengl feature is active
    # TODO: Lookinto these are they needed or already installed?
    # OR attach this to a specialization
    # (example) https://code.m3tam3re.com/m3tam3re/nixos-config/src/commit/39e11879486183522a9ecb5cdb44d7c96db508ee/home/m3tam3re/m3-kratos.nix
	# For nvidia GPU + intel CPU w/ iGPU
	hardware.graphics.extraPackages = mkDefault (with pkgs; [
		# intel-media-driver
		nvidia-vaapi-driver
	]);

    hardware.nvidia = {
		open = mkDefault false;
		modesetting.enable = mkDefault true;
		powerManagement.enable = mkDefault false;
		nvidiaSettings = mkDefault true;
		package = mkDefault config.boot.kernelPackages.nvidiaPackages.stable;
	};
  };
}
