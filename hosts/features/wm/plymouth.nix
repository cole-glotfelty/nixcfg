{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.wm.plymouth;
in {
  options.features.wm.plymouth.enable = mkEnableOption "enable plymouth";

  config = mkIf cfg.enable {
    boot.plymouth = {
      enable = true;
    };
  };
}
