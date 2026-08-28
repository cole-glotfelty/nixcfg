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
      terminal = mkDefault "tmux-256color";

      # Persist session/window/pane layouts across crashes and reboots.
      # Manual save: Ctrl-a Ctrl-s. Manual restore: Ctrl-a Ctrl-r.
      plugins = with pkgs.tmuxPlugins; [
        resurrect
        {
          plugin = continuum;
          extraConfig = ''
            set -g @continuum-restore 'on'
            set -g @continuum-save-interval '5'
            set -g @resurrect-delete-backup-after '7'
          '';
        }
      ];

      extraConfig = let
        c = config.features.style.colors.palette.dark;
        # Battery widget (macOS pmset + Nerd Font glyphs). Darwin only.
        # Read verbatim from a file so the Nerd Font glyphs survive intact.
        battery = pkgs.writeShellScript "tmux-battery"
          (builtins.readFile ./tmux/battery.sh);
        # continuum's periodic save is triggered by interpolating its save
        # script into status-right; do not remove this from the status line.
        continuumSave =
          "${pkgs.tmuxPlugins.continuum}/share/tmux-plugins/continuum/scripts/continuum_save.sh";
        batterySeg = optionalString pkgs.stdenv.isDarwin
          "#[fg=#${c.yellow}]#(${battery})  ";
      in ''
        setw -g pane-base-index 1
        set -g clock-mode-style 24
        set -ga terminal-overrides ",screen-256color*:Tc"

        # Let OSC 8 hyperlinks through to the outer terminal (ghostty/kitty
        # both support them). Without this tmux strips them.
        set -ga terminal-features "*:hyperlinks"

        # Forward DECSCUSR cursor-shape sequences so programs inside tmux
        # (zsh vim-mode plugin, neovim) can change the cursor shape in Ghostty.
        # Without this tmux strips them and the cursor stays a static block.
        set -ga terminal-overrides '*:Ss=\E[%p1%d q:Se=\E[2 q'

        set-option -g update-environment "PROJECT_DIRS"

        bind -T copy-mode-vi v send-keys -X begin-selection
        bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel '${config.custom.defaults.copyCommand}'
        bind-key -r f run-shell "tmux neww ${pkgs.tmux-sessionizer}/bin/tmux-sessionizer"

        # ── Status bar: Tokyo Night Storm, flat + Nerd Font icons ──────────
        set -g status-style "bg=#${c.bgDark},fg=#${c.fg}"
        set -g status-left-length 40
        set -g status-right-length 90
        set -g status-left "#[fg=#${c.magenta},bold]  #S #[default]"
        set -g status-right "#(${continuumSave})${batterySeg}#[fg=#${c.cyan}] %H:%M #[fg=#${c.comment}]%d-%b #[default]"

        # Claude-window naming + per-command Nerd Font icons in the window tabs.
        # Red block = Claude Code is awaiting input (set by the claude-code
        # hooks). Sourced verbatim to keep the icon glyphs byte-intact.
        ${builtins.readFile ./tmux/window-status.conf}

        # Panes: dim border, bright active, title bar only when window is split.
        set -g pane-border-style "fg=#${c.border}"
        set -g pane-active-border-style "fg=#${c.blue}"
        set -g pane-border-format " #{?pane_active,#[fg=#${c.blue}#,bold],#[fg=#${c.comment}]}#{pane_index} #{pane_title} #[default]"
        set-hook -g window-layout-changed 'if -F "#{==:#{window_panes},1}" "set -w pane-border-status off" "set -w pane-border-status top"'
      '';
    };
  };
}
