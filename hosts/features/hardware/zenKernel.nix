{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.hardware.zenKernel;
in {
  options.features.hardware.zenKernel.enable =
    mkEnableOption "enable zenKernel";

  config = mkIf cfg.enable { boot.kernelPackages = pkgs.linuxPackages_zen; };
}
