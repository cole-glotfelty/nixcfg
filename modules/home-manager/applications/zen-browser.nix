{ inputs, config, lib, pkgs, ... }:

with lib;
let
  cfg = config.features.applications.zen-browser;
in {
  options.features.applications.zen-browser = {
    enable = mkEnableOption (lib.mdDoc ''
      Zen Browser - modern Firefox-based browser with enhanced UX.

      Configuration:
      - Installs from zen-browser flake input
      - Currently supports x86_64-linux and aarch64-linux architectures
      - macOS support pending upstream package availability

      Note: Installation may fail if wrapGAppsHook migration is incomplete.
      This is an upstream issue that should resolve in future updates.

      Dependencies: zen-browser flake input
    '');
  };

  config = mkIf cfg.enable {
    # Only install on supported Linux platforms
    home.packages = mkIf pkgs.stdenv.isLinux (
      let
        system = pkgs.stdenv.hostPlatform.system;
        zenPackage = inputs.zen-browser.packages.${system}.default or null;
      in
        if zenPackage != null then [ zenPackage ]
        else throw "Zen Browser is not available for system: ${system}"
    );

    # TODO: Add macOS support when available
    warnings = mkIf (cfg.enable && pkgs.stdenv.isDarwin) [
      "Zen Browser is not yet available for macOS. Package will not be installed."
    ];
  };
}
