{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.cli.tmux;
in {
  options.features.cli.tmux = {
    enable = mkEnableOption (lib.mdDoc ''
      Tmux terminal multiplexer with vi-mode and development optimizations.
      
      Features:
      - Vi-style key bindings and copy mode selection
      - Mouse support for modern terminal interaction
      - Ctrl-a prefix (screen-compatible) with 24-hour clock
      - 256-color terminal support with true color passthrough
      - Copy integration with system clipboard via custom.defaults.copyCommand
      - Tmux-sessionizer integration for project switching (Ctrl-a f)
      - PROJECT_DIRS environment variable forwarding
      
      Dependencies: custom.defaults.copyCommand, tmux-sessionizer package
    '');
  };
  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = config.custom.defaults.copyCommand != "";
        message = ''
          Tmux module requires a clipboard utility for copy-paste functionality.
          
          Current value: '${config.custom.defaults.copyCommand}'
          
          Fix by adding to your configuration:
            custom.defaults.copyCommand = "wl-copy";  # For Wayland
            # OR
            custom.defaults.copyCommand = "xclip";    # For X11
            # OR
            custom.defaults.copyCommand = "pbcopy";   # For macOS
          
          This enables Ctrl-a y to copy selected text to system clipboard.
        '';
      }
    ];
    
    programs.tmux = {
      enable = true;
      mouse = mkDefault true;
      clock24 = mkDefault true;
      keyMode = mkDefault "vi";
      prefix = mkDefault "C-a";
      baseIndex = mkDefault 1;
      terminal = mkDefault "screen-256color";
      extraConfig = let
        colors = config.features.style.colors.palette.dark;
      in ''
        set -ga terminal-overrides ",screen-256color*:Tc"
        set -g status-style 'bg=#${colors.bgDark} fg=#${colors.cyan}'

        set-option -g update-environment "PROJECT_DIRS"

        bind -T copy-mode-vi v send-keys -X begin-selection
        bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel '${config.custom.defaults.copyCommand}'
        bind-key -r f run-shell "tmux neww ${pkgs.tmux-sessionizer}/bin/tmux-sessionizer"
      '';
    };
  };
}
