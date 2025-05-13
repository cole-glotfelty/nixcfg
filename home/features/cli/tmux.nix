{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.cli.tmux;
in {
  options.features.cli.tmux.enable = mkEnableOption "enable tmux configuration";
  config = mkIf cfg.enable {
    programs.tmux = {
      enable = true;
      mouse = true;
      clock24 = true;
      keyMode = "vi";
      prefix = "C-a";
      baseIndex = 1;
      terminal = "screen-256color";
      # TODO: Come back here and update colors to match nix-colors
      # TODO: come back and packaged tmux-sessionizer script
      extraConfig = ''
        set -ga terminal-overrides ",screen-256color*:Tc"
        set -g status-style 'bg=#333333 fg=#5eacd3'

        set-option -g update-environment "PROJECT_DIRS"

        bind -T copy-mode-vi v send-keys -X begin-selection
        bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'wl-copy'
        bind-key -r f run-shell "tmux neww ${pkgs.tmux-sessionizer}/bin/tmux-sessionizer"
      '';
    };
  };
}
