{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.hardware.intel;
in {
  options.features.hardware.intel.enable = mkEnableOption "enable intel";

  config = mkIf cfg.enable {
    # it's GPU specific this is for intel iGPU
    # TODO: Potenitally make this only enable if opengl feature is active
    # OR attach this to a specialization
    # (example) https://code.m3tam3re.com/m3tam3re/nixos-config/src/commit/39e11879486183522a9ecb5cdb44d7c96db508ee/home/m3tam3re/m3-kratos.nix
    hardware.graphics.extraPackages = with pkgs; [
      intel-compute-runtime
      intel-media-driver
      intel-vaapi-driver
      intel-ocl
      mesa
    ];
  };
}
