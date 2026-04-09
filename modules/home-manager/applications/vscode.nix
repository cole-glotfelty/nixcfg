{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.applications.vscode;
in {
  options.features.applications.vscode.enable = mkEnableOption (lib.mdDoc ''
  '');
  config = mkIf cfg.enable {
    programs.vscode= {
      enable = true;
      # TODO: Fix this/make it work
      # extensions = with pkgs.vscode-extensions; [
      #   Natizyskunk.sftp
      # ];
    };
  };
}
