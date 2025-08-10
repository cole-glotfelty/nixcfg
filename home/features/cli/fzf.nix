{ config, lib, ... }:

with lib;
let cfg = config.features.cli.fzf;
in {
  options.features.cli.fzf = {
    enable = mkEnableOption (lib.mdDoc ''
      FZF fuzzy finder with basic configuration for file and command searching.
      
      Features:
      - Command-line fuzzy finder for files, history, and processes
      - Basic configuration without shell integration (currently disabled)
      - Foundation for interactive file selection and command history search
      
      TODO: Shell integration, color themes, preview options, custom keybinds
      Works with: Any shell, integrates with various CLI tools
    '');
  };

  config = mkIf cfg.enable {
    # TODO: Come back and add color (nix-colors), tmuxIntegration, defualtOpts
    # preview and toggle the preview (Sascha Koenig pt4, 5:46)
    programs.fzf = {
      enable = true;
      # TODO: Change keybinds on this
      # enableZshIntegration = mkDefault true;
      # enableBashIntegration = mkDefault true;
    };
  };
}
