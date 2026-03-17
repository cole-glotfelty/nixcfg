{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.apps.nixd;
in {
  options.features.apps.nixd.enable = mkEnableOption (lib.mdDoc ''
    Nixd language server for Nix development.

    Features:
    - LSP support for Nix expressions
    - Code completion and diagnostics
    - Go-to-definition and hover documentation

    Use with: NixVim, VS Code, or any LSP-compatible editor
  '');

  config =
    # TODO: I might need to append to nixpath
    mkIf cfg.enable { environment.systemPackages = with pkgs; [ nixd ]; };
}
