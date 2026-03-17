{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.cli.fzf;
in {
  options.features.cli.fzf = {
    enable = mkEnableOption (lib.mdDoc ''
      FZF fuzzy finder with file previews.

      Features:
      - Command-line fuzzy finder for files, history, and processes
      - Syntax-highlighted file previews via bat
      - Directory previews via tree
      - Uses terminal's color palette (automatically follows terminal theme)

      Keybinds (when shell integration enabled):
      - Ctrl+T: File search with preview
      - Ctrl+R: History search
      - Alt+C: Directory search with preview

      Works with: Any shell, integrates with various CLI tools
    '');
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      bat   # Syntax-highlighted file preview
      tree  # Directory preview
    ];

    programs.fzf = {
      enable = true;
      enableZshIntegration = mkDefault true;
      enableBashIntegration = mkDefault true;

      # Ctrl+T: File widget with bat preview
      fileWidgetOptions = [
        "--preview '${pkgs.bat}/bin/bat --color=always --style=numbers --line-range=:500 {} 2>/dev/null || cat {}'"
        "--preview-window 'right:60%:wrap'"
      ];

      # Alt+C: Directory widget with tree preview
      changeDirWidgetOptions = [
        "--preview '${pkgs.tree}/bin/tree -C {} | head -200'"
        "--preview-window 'right:50%:wrap'"
      ];

      # Ctrl+R: History widget (no preview needed)
      historyWidgetOptions = [
        "--preview-window 'hidden'"
      ];
    };
  };
}
