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

    cudaCapabilities = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [ "6.1" ];
      description = lib.mdDoc ''
        CUDA compute capability of this GPU (e.g. "6.1" for Pascal/GTX 10-series).

        nixpkgs' default CUDA build only targets Turing and newer
        (compute capability >= 7.5); `pkgs.ollama-cuda` silently falls
        back to CPU-only inference on older cards unless a consumer
        (e.g. features.apps.ollama) rebuilds it for this capability,
        since its compiled binaries don't include the older architecture
        at all. Not applied globally (setting `nixpkgs.config.cudaCapabilities`
        directly breaks CUDA packages such as cuDNN that don't support
        pre-Turing architectures at all).

        Find your card's value at https://developer.nvidia.com/cuda-gpus.
      '';
    };
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
		# Saves/restores VRAM across S3/hibernate via nvidia-{suspend,resume,hibernate}.service
		# and NVreg_PreserveVideoMemoryAllocations=1. Without it the GPU channels are
		# invalid on resume (Xid 13), killing Hyprland and hyprlock.
		powerManagement.enable = mkDefault true;
		nvidiaSettings = mkDefault true;
		package = mkDefault config.boot.kernelPackages.nvidiaPackages.stable;
	};

    # Required for NVIDIA on Wayland (Hyprland/XWayland) and Wayland-native GLFW apps
    environment.sessionVariables = mkDefault {
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      GBM_BACKEND = "nvidia-drm";
      LIBVA_DRIVER_NAME = "nvidia";
      GLFW_PLATFORM = "wayland";
    };
  };
}
