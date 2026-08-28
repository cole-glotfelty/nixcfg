{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.features.wm.tuigreet;

  # tuigreet is a *terminal* UI, not a Wayland client. It must run directly on
  # the VT so it can drive the console with ANSI escapes. Do not wrap it in a
  # compositor (cage/kiosk): that puts the VT into KD_GRAPHICS, swallows the
  # escape sequences, and leaves a frozen screen with no greeter -- the
  # compositor has no Wayland client to display, and tuigreet's crossterm
  # reader panics with "reader source not set".
  tuigreet = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session --cmd start-hyprland";
in {
  options.features.wm.tuigreet.enable = mkEnableOption (lib.mdDoc ''
    greetd display manager with the tuigreet TUI greeter on TTY1.

    Replaces ly with a greeter that hands off to Hyprland cleanly on
    multi-monitor setups. tuigreet renders on the bare KMS console, so on a
    mixed-resolution setup the console framebuffer uses a single mode and the
    higher-resolution panel may letterbox. That is cosmetic; a Wayland greeter
    (gtkgreet/regreet inside cage) is the only way to render each output at its
    native mode.

    Dependencies: a session command on PATH (start-hyprland)
  '');

  config = mkIf cfg.enable {
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = tuigreet;
          user = "greeter";
        };
      };
    };
  };
}
