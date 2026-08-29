{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.features.cli.claude-code;
  jsonFormat = pkgs.formats.json { };

  # Declarative ~/.claude/settings.json. Runtime state (onboarding flags,
  # per-project prefs) lives in ~/.claude.json and settings.local.json, which
  # Claude Code still owns — only this user-level config is managed here.
  settings = {
    permissions.defaultMode = "auto";

    # Hooks drive the tmux "awaiting input" indicator: they toggle the
    # @claude_waiting window option that tmux.nix paints red in the status bar.
    hooks = let
      setWaiting = "[ -n \"$TMUX_PANE\" ] && tmux set -w -t \"$TMUX_PANE\" @claude_waiting 1 >/dev/null 2>&1; exit 0";
      clearWaiting = "[ -n \"$TMUX_PANE\" ] && tmux set -w -t \"$TMUX_PANE\" -u @claude_waiting >/dev/null 2>&1; exit 0";
      hook = command: [{ hooks = [{ type = "command"; inherit command; }]; }];
    in {
      Notification = hook setWaiting;
      Stop = hook setWaiting;
      UserPromptSubmit = hook clearWaiting;
      SessionEnd = hook clearWaiting;
      SessionStart = hook clearWaiting;
    };

    statusLine = {
      type = "command";
      command = "~/.claude/statusline.sh";
      hideVimModeIndicator = true;
    };

    outputStyle = "Concise";
    tui = "fullscreen";
    advisorModel = "opus";
    skipWorkflowUsageWarning = true;
    theme = "dark";
    editorMode = "vim";
    remoteControlAtStartup = true;
    inputNeededNotifEnabled = true;
    model = "sonnet";
  };
in {
  options.features.cli.claude-code.enable = mkEnableOption (lib.mdDoc ''
    Declarative Claude Code (~/.claude) configuration.

    Manages:
    - settings.json — hooks, statusline, and editor/model defaults
    - statusline.sh — model / effort / context-bar / session-cost status line

    The hooks integrate with features.cli.tmux: they set a @claude_waiting
    window flag that the tmux status bar paints red while Claude is awaiting
    your input.

    NOTE: settings.json is a read-only symlink into the Nix store, so changing
    model/theme via Claude's slash commands won't persist — edit this module
    instead. The claude-code package itself is installed from cli/default.nix.
  '');

  config = mkIf cfg.enable {
    home.file.".claude/settings.json".source =
      jsonFormat.generate "claude-settings.json" settings;

    home.file.".claude/statusline.sh" = {
      source = ./claude/statusline.sh;
      executable = true;
    };
  };
}
