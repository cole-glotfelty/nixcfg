{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.hardware.nvidia;
in {
  options.features.hardware.nvidia.enable =
    mkEnableOption "enable nvidia";

  config = mkIf cfg.enable {
	services.xserver.videoDrivers = [ "nvidia" ];

    # Note on extra packages:
    # it's GPU specific this is for intel iGPU
    # TODO: Potenitally make this only enable if opengl feature is active
    # TODO: Lookinto these are they needed or already installed?
    # OR attach this to a specialization
    # (example) https://code.m3tam3re.com/m3tam3re/nixos-config/src/commit/39e11879486183522a9ecb5cdb44d7c96db508ee/home/m3tam3re/m3-kratos.nix
	# For nvidia GPU + intel CPU w/ iGPU
	hardware.graphics.extraPackages = with pkgs; [
		# intel-media-driver
		nvidia-vaapi-driver
	];

    hardware.nvidia = {
		open = false;
		modesetting.enable = true;
		powerManagement.enable = false;
		nvidiaSettings = true;
		package = config.boot.kernelPackages.nvidiaPackages.stable;
	};
  };
}
