{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.desktop.hyprland;
in {
  options.features.desktop.hyprland = {
    enable = mkEnableOption (lib.mdDoc ''
      Hyprland Wayland compositor for the user environment.

      **System Dependencies**: Enabling this option automatically configures
      the following system-level components on NixOS hosts:
      • Hyprland compositor system package
      • Ly display manager for session management
      • GNOME Keyring integration
      • Wayland environment variables and optimizations
      • Hyprpolkitagent for privilege escalation
      • Hardware cursor workarounds for compatibility

      This ensures the desktop environment works seamlessly without
      manual host configuration.
    '');

    monitors = mkOption {
      type = types.listOf (types.strMatching "^[^,]*,[^,]+,[^,]+,[^,]+$");
      default = [ ", preferred, auto, auto" ];
      description = "Monitor configuration strings for Hyprland (only used when Hyprland is enabled)";
      example = [
        "HDMI-A-1,1920x1080@75,0x0,1"
        "HDMI-A-2,1920x1080@75,1920x0,1"
      ];
    };
  };

  config = mkIf cfg.enable {
    warnings = optional pkgs.stdenv.isDarwin
      "Hyprland is enabled but you're on macOS. Hyprland is a Linux Wayland compositor and won't work on macOS.";

    assertions = [
      {
        assertion = pkgs.stdenv.isLinux;
        message = ''
          Hyprland is only supported on Linux systems.

          Current platform: ${pkgs.stdenv.hostPlatform.system}

          Hyprland is a Wayland compositor for Linux. For other platforms:
            • macOS: Use native window management or tools like yabai
            • Other systems: Consider alternative window managers
        '';
      }
      {
        assertion = config.features.desktop.wayland.enable;
        message = ''
          Hyprland requires Wayland utilities to function properly.

          Missing dependency: features.desktop.wayland.enable = false

          Fix by adding to your configuration:
            features.desktop.wayland.enable = true;

          This provides essential tools:
            • grim + slurp: Screenshot capture and area selection
            • wl-clipboard: Wayland clipboard utilities (wl-copy, wl-paste)
            • wlogout: Logout menu integration
            • Qt Wayland support for GUI applications
        '';
      }
    ];

    home.packages = with pkgs; [
      pavucontrol
      networkmanagerapplet
      awww
      hyprpicker
      playerctl
    ];

    # Set Cursor
    home.pointerCursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 24;
      gtk.enable = true;
    };

    # TODO: Add hyprlock config and use it here
    programs.hyprlock = {
      enable = true;
    };

    services.hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd         = "pidof hyprlock || hyprlock";
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd  = "hyprctl dispatch dpms on";
        };
        listener = [
          { timeout = 600;  on-timeout = "loginctl lock-session"; }
          { timeout = 1800; on-timeout = "systemctl suspend"; }
          { timeout = 3600; on-timeout = "systemctl hibernate"; }
        ];
      };
    };

    wayland.windowManager.hyprland = {
      enable = true;
      configType = "lua";
      xwayland.enable = true;
      package = null;
      portalPackage = null;
      systemd.variables = [ "--all" ];
      # settings is intentionally empty — all config lives in extraConfig using the
      # Hyprland 0.56 Lua API (hl.config, hl.curve, hl.animation, hl.window_rule, etc.)
      # The settings attribute generates hl.<key>() calls which don't exist in 0.56 Lua.
      settings = {};
      extraConfig =
        let
          terminal  = config.custom.defaults.terminal;
          colors    = config.features.style.colors.palette.dark;
          wallpaper = ../../../users/common/mountain_oblisk.jpg;
          monitorLua = lib.concatMapStrings
            (m:
              let
                parts    = lib.splitString "," m;
                output   = lib.strings.trim (lib.elemAt parts 0);
                mode     = lib.strings.trim (lib.elemAt parts 1);
                position = lib.strings.trim (lib.elemAt parts 2);
                scale    = lib.strings.trim (lib.elemAt parts 3);
              in
                "hl.monitor({ output = \"${output}\", mode = \"${mode}\", position = \"${position}\", scale = \"${scale}\" })\n"
            )
            cfg.monitors;
        in ''
          -- Monitors
          ${monitorLua}

          -- Variables
          local terminal = "${terminal}"
          local menu     = "fuzzel"
          local mainMod  = "SUPER"

          -- Environment variables
          hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
          hl.env("XDG_SESSION_DESKTOP", "Hyprland")
          hl.env("XDG_SESSION_TYPE",    "wayland")
          hl.env("HYPRCURSOR_THEME",    "Bibata-Modern-Classic")
          hl.env("HYPRCURSOR_SIZE",     "24")
          hl.env("XCURSOR_SIZE",        "24")

          -- Main config
          hl.config({
            general = {
              gaps_in      = 5,
              gaps_out     = 20,
              border_size  = 2,
              col = {
                active_border   = { colors = {"rgba(${colors.cyan}ee)", "rgba(${colors.green}ee)"}, angle = 45 },
                inactive_border = "rgba(${colors.comment}aa)",
              },
              resize_on_border = false,
              allow_tearing    = false,
              layout           = "dwindle",
            },
            decoration = {
              rounding         = 10,
              active_opacity   = 1.0,
              inactive_opacity = 1.0,
              shadow = {
                enabled      = true,
                range        = 4,
                render_power = 3,
                color        = "rgba(${colors.bg}ee)",
              },
              blur = {
                enabled  = true,
                size     = 6,
                passes   = 2,
                xray     = true,
                vibrancy = 0.1696,
              },
            },
            animations = { enabled = true },
            dwindle    = { preserve_split = true },
            master     = { new_status = "master" },
            misc = {
              force_default_wallpaper = 0,
              disable_hyprland_logo   = true,
            },
            input = {
              kb_layout    = "us",
              kb_variant   = "",
              kb_model     = "",
              kb_options   = "",
              kb_rules     = "",
              follow_mouse = 1,
              sensitivity  = 0,
              touchpad     = { natural_scroll = false },
            },
          })

          -- Bezier curves
          hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
          hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}    } })
          hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}       } })
          hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1.0}  } })
          hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })

          -- Animations
          hl.animation({ leaf = "global",        enabled = true, speed = 10,   bezier = "default"      })
          hl.animation({ leaf = "border",        enabled = true, speed = 5.39, bezier = "easeOutQuint" })
          hl.animation({ leaf = "windows",       enabled = true, speed = 4.79, bezier = "easeOutQuint" })
          hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4.1,  bezier = "easeOutQuint", style = "popin 87%" })
          hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.49, bezier = "linear",       style = "popin 87%" })
          hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "almostLinear" })
          hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "almostLinear" })
          hl.animation({ leaf = "fade",          enabled = true, speed = 3.03, bezier = "quick"        })
          hl.animation({ leaf = "layers",        enabled = true, speed = 3.81, bezier = "easeOutQuint" })
          hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
          hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })
          hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.79, bezier = "almostLinear" })
          hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
          hl.animation({ leaf = "workspaces",    enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })

          -- Keybindings
          hl.bind(mainMod .. " + RETURN",         hl.dsp.exec_cmd(terminal))
          hl.bind(mainMod .. " + SHIFT + RETURN", hl.dsp.exec_cmd("ghostty-light"))
          hl.bind(mainMod .. " + SHIFT + Q",      hl.dsp.window.close())
          hl.bind(mainMod .. " + D",              hl.dsp.exec_cmd(menu))
          hl.bind(mainMod .. " + SHIFT + L",      hl.dsp.exec_cmd("hyprlock"))
          hl.bind(mainMod .. " + L",              hl.dsp.exec_cmd("wlogout"))
          hl.bind(mainMod .. " + M",              hl.dsp.exec_cmd("hyprctl dispatch exit"))
          hl.bind(mainMod .. " + F",              hl.dsp.window.fullscreen())
          hl.bind(mainMod .. " + V",              hl.dsp.window.float({ action = "toggle" }))
          hl.bind(mainMod .. " + SHIFT + S",      hl.dsp.exec_cmd([[grim -l 0 -g "$(slurp)" - | wl-copy]]))

          -- Focus with hjkl
          hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left"  }))
          hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
          hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up"    }))
          hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down"  }))

          -- Workspaces 1-9
          for i = 1, 9 do
            hl.bind(mainMod .. " + " .. i,         hl.dsp.focus({ workspace = i }))
            hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
          end
          -- Workspace 10 (key 0)
          hl.bind(mainMod .. " + 0",         hl.dsp.focus({ workspace = 10 }))
          hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))

          -- Special workspace (scratchpad)
          hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
          hl.bind("ALT + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

          -- Scroll through workspaces
          hl.bind(mainMod .. " + mouse_down",         hl.dsp.focus({ workspace = "e+1" }))
          hl.bind(mainMod .. " + mouse_up",           hl.dsp.focus({ workspace = "e-1" }))
          hl.bind(mainMod .. " + SHIFT + mouse_down", hl.dsp.window.move({ workspace = "e+1" }))
          hl.bind(mainMod .. " + SHIFT + mouse_up",   hl.dsp.window.move({ workspace = "e-1" }))

          -- Move/resize with mouse
          hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
          hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

          -- Multimedia keys (locked + repeating)
          hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
          hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
          hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
          hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
          hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl s 10%+"),                           { locked = true, repeating = true })
          hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%-"),                           { locked = true, repeating = true })

          -- Media keys (locked)
          hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),        { locked = true })
          hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"),  { locked = true })
          hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"),  { locked = true })
          hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),    { locked = true })

          -- Window rules
          hl.window_rule({
            name  = "suppress-maximize",
            match = { class = ".*" },
            suppress_event = "maximize",
          })

          hl.window_rule({
            name  = "fix-xwayland-drag",
            match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
            no_focus = true,
          })

          -- Picture-in-Picture
          hl.window_rule({
            name  = "pip",
            match = { title = "^Picture%-in%-Picture$" },
            float = true, pin = true, size = "640 360", move = "(monitor_w-660) (monitor_h-380)",
          })

          hl.window_rule({
            name  = "pip-browsers",
            match = { class = "^(firefox|LibreWolf|brave%-browser)$", title = ".*Picture%-in%-Picture.*" },
            float = true, pin = true, size = "640 360", move = "(monitor_w-660) (monitor_h-380)",
          })

          -- Bitwarden popups
          hl.window_rule({
            name  = "bitwarden-brave",
            match = { initial_class = "^brave%-.*%-Default$" },
            float = true, size = "400 600",
          })

          hl.window_rule({
            name  = "bitwarden-firefox",
            match = { class = "^(firefox|librewolf)$", title = ".*Bitwarden.*" },
            float = true, size = "400 600",
          })

          -- Autostart (hypridle is managed by its systemd service; waybar by systemd)
          hl.on("hyprland.start", function()
            hl.exec_cmd("awww-daemon")
            hl.exec_cmd("sleep 0.5 && mullvad-vpn")
            hl.exec_cmd("awww img ${wallpaper}")
            hl.exec_cmd("fcitx5")
          end)

          -- Restart the systemd-managed waybar when a monitor reconnects
          -- (e.g. after turning off/on). Restarting the service keeps a single
          -- instance instead of spawning duplicates per monitor.
          hl.on("monitor.added", function()
            hl.exec_cmd("systemctl --user restart waybar.service")
          end)
        '';
    };
  };
}
