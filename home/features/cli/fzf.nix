{ config, lib, ... }:

with lib;
let cfg = config.features.cli.fzf;
in {
  options.features.cli.fzf.enable = mkEnableOption "enable fzf configuration";

  config = mkIf cfg.enable {
    # TODO: Come back and add color (nix-colors), tmuxIntegration, defualtOpts
    # preview and toggle the preview (Sascha Koenig pt4, 5:46)
    programs.fzf = {
      enable = true;
      # TODO: Change keybinds on this
      # enableZshIntegration = true;
      # enableBashIntegration = true;
    };
  };
}
