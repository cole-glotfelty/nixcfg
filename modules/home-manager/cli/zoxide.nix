{ config, lib, ... }:

with lib;
let cfg = config.features.cli.zoxide;
in {
  options.features.cli.zoxide = {
    enable = mkEnableOption (lib.mdDoc ''
      Zoxide smart directory jumper with frecency-based navigation.
      
      Features:
      - Smart cd replacement using frecency algorithm (frequency + recency)
      - Integration with shell history for directory navigation
      - "z" command for quick directory switching
      - Learning from directory usage patterns
      
      Integrates with: Zsh (via zsh.nix initContent), Bash
      Replaces: Traditional cd command with intelligent directory jumping
    '');
  };

  config = mkIf cfg.enable {
    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
    };
  };
}
