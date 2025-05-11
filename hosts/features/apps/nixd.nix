{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.apps.nixd;
in {
  options.features.apps.nixd.enable = mkEnableOption "enable nixd (Nix LSP)";

  config =
    # TODO: I might need to append to nixpath
    mkIf cfg.enable { environment.systemPackages = with pkgs; [ nixd ]; };
}
