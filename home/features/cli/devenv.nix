{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.cli.devenv;
in {
  options.features.cli.devenv.enable = mkEnableOption "enable devenv";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ devenv ];
    programs = {
      direnv = {
        enable = true;
        enableZshIntegration = true;
        nix-direnv.enable = true;
      };
      zsh = {
        enable = true;
        initContent = ''eval "$(direnv hook zsh)"'';
      };
    };

    # home.activation.createDevenvCacheDir =
    #   lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    #     $DRY_RUN_CMD mkdir -p $HOME/.devenv-cache/nix/tarball-cache
    #     $DRY_RUN_CMD chmod 755 $HOME/.devenv-cache/nix/tarball-cache
    #   '';
    #
    # home.sessionVariables = {
    #   NIX_TARBALL_CACHE_DIR = "$HOME/.devenv-cache/nix/tarball-cache";
    # };

    # nix = {
    #   settings = {
    #     tarball-cache-dir = "$HOME/.devenv-cache/nix/tarball-cache";
    #   };
    # };
  };
}
