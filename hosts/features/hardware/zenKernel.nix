{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.hardware.zenKernel;
in {
  options.features.hardware.zenKernel = {
    enable = mkEnableOption (lib.mdDoc ''
      Zen Linux kernel for enhanced desktop performance.
      
      Features:
      - Linux kernel optimized for desktop and gaming workloads
      - Lower latency and improved responsiveness
      - Enhanced scheduler for interactive applications
      - Better performance for multimedia and gaming
      
      Use case: Desktop systems prioritizing responsiveness over server stability
      Dependencies: x86_64 architecture
      Alternative to: Standard Linux kernel for server-focused optimization
    '');
  };

  config = mkIf cfg.enable { boot.kernelPackages = pkgs.linuxPackages_zen; };
}
