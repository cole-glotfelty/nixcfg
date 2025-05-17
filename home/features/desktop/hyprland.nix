{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.desktop.hyprland;
in {
  options.features.desktop.hyprland.enable = mkEnableOption "enable hyprland";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      pavucontrol
      networkmanagerapplet
      swww
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
      # settings = {
      #
      # };
    };

    services.hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd =
            "pidof hyprlock || hyprlock"; # avoid starting multiple hyprlock instances.
          before_sleep_cmd = "loginctl lock-session"; # lock before suspend.
          after_sleep_cmd =
            "hyprctl dispatch dpms on"; # to avoid having to press a key twice to turn on the display.
        };
        listener = [
          {
            timeout = 600; # in seconds.
            on-timeout = "loginctl lock-session";
          }
          {
            timeout = 1800; # in seconds.
            on-timeout = "systemctl suspend";
          }
          {
            timeout = 3600; # in seconds.
            on-timeout = "systemctl hibernate";
          }
        ];
      };
    };

    wayland.windowManager.hyprland = {
      enable = true;
      # systemd.enable = false;
      xwayland.enable = true;
      package = null;
      portalPackage = null;
      systemd.variables = [ "--all" ];
      settings = {
        # Setting Programs to Use
        "$terminal" = "kitty";
        "$menu" = "fuzzel";

        # See https://wiki.hyprland.org/Configuring/Environment-variables/
        env = [
          "XDG_CURRENT_DESKTOP,Hyprland"
          "XDG_SESSION_DESKTOP,Hyprland"
          "XDG_SESSION_TYPE,wayland"
          "HYPRCURSOR_THEME,Bibata-Modern-Classic"
          "HYPRCURSOR_SIZE,24"
          "XCURSOR_SIZE,24"
        ];

        ## AUTOSTART ##
        exec-once = [
          "swww-daemon &"
          "swww img ../../common/mountain_oblisk.jpg &"
          "waybar &"
          "nm-applet &"
          "fcitx5 &"
          "hypridle &"
        ];

        ## INPUTS ##
        # https://wiki.hyprland.org/Configuring/Variables/#input
        input = {
          kb_layout = "us";
          kb_variant = "";
          kb_model = "";
          kb_options = "";
          kb_rules = "";

          follow_mouse = 1;

          sensitivity = 0; # -1.0 - 1.0, 0 means no modification.

          touchpad = { natural_scroll = false; };
        };

        # https://wiki.hyprland.org/Configuring/Variables/#gestures
        gestures = { workspace_swipe = false; };

        ## LOOK & FEEL ##
        # Refer to https://wiki.hyprland.org/Configuring/Variables/
        # https://wiki.hyprland.org/Configuring/Variables/#general
        general = {
          gaps_in = 5;
          gaps_out = 20;

          border_size = 2;

          # https://wiki.hyprland.org/Configuring/Variables/#variable-types for info about colors
          "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
          "col.inactive_border" = "rgba(595959aa)";

          # Set to true enable resizing windows by clicking and dragging on borders and gaps
          resize_on_border = false;

          # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
          allow_tearing = false;

          layout = "dwindle";
        };

        # https://wiki.hyprland.org/Configuring/Variables/#decoration
        decoration = {
          rounding = 10;

          # Change transparency of focused and unfocused windows
          active_opacity = 1.0;
          inactive_opacity = 1.0;

          shadow = {
            enabled = true;
            range = 4;
            render_power = 3;
            color = "rgba(1a1a1aee)";
          };

          # https://wiki.hyprland.org/Configuring/Variables/#blur
          blur = {
            enabled = true;
            size = 3;
            passes = 1;

            vibrancy = 0.1696;
          };
        };

        # https://wiki.hyprland.org/Configuring/Variables/#animations
        animations = {
          enabled = "yes, please :)";

          # Default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

          bezier = [
            "easeOutQuint,0.23,1,0.32,1"
            "easeInOutCubic,0.65,0.05,0.36,1"
            "linear,0,0,1,1"
            "almostLinear,0.5,0.5,0.75,1.0"
            "quick,0.15,0,0.1,1"
          ];

          animation = [
            "global, 1, 10, default"
            "border, 1, 5.39, easeOutQuint"
            "windows, 1, 4.79, easeOutQuint"
            "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
            "windowsOut, 1, 1.49, linear, popin 87%"
            "fadeIn, 1, 1.73, almostLinear"
            "fadeOut, 1, 1.46, almostLinear"
            "fade, 1, 3.03, quick"
            "layers, 1, 3.81, easeOutQuint"
            "layersIn, 1, 4, easeOutQuint, fade"
            "layersOut, 1, 1.5, linear, fade"
            "fadeLayersIn, 1, 1.79, almostLinear"
            "fadeLayersOut, 1, 1.39, almostLinear"
            "workspaces, 1, 1.94, almostLinear, fade"
          ];
        };

        # Ref https://wiki.hyprland.org/Configuring/Workspace-Rules/
        # "Smart gaps" / "No gaps when only"
        # uncomment all if you wish to use that.
        # workspace = w[t1], gapsout:0, gapsin:0
        # workspace = w[tg1], gapsout:0, gapsin:0
        # workspace = f[1], gapsout:0, gapsin:0
        # windowrulev2 = bordersize 0, floating:0, onworkspace:w[t1]
        # windowrulev2 = rounding 0, floating:0, onworkspace:w[t1]
        # windowrulev2 = bordersize 0, floating:0, onworkspace:w[tg1]
        # windowrulev2 = rounding 0, floating:0, onworkspace:w[tg1]
        # windowrulev2 = bordersize 0, floating:0, onworkspace:f[1]
        # windowrulev2 = rounding 0, floating:0, onworkspace:f[1]

        # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
        dwindle = {
          pseudotile =
            true; # Master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
          preserve_split = true; # You probably want this
        };

        # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
        master = { new_status = "master"; };

        # https://wiki.hyprland.org/Configuring/Variables/#misc
        misc = {
          force_default_wallpaper =
            0; # Set to 0 or 1 to disable the anime mascot wallpapers
          disable_hyprland_logo =
            true; # If true disables the random hyprland logo / anime girl background. :(
        };

        ## KEYMAPS ##
        "$mainMod" = "SUPER";

        bind = [
          "$mainMod, RETURN, exec, $terminal"
          "$mainMod SHIFT, Q, killactive"
          "$mainMod, D, exec, $menu"
          "$mainMod, L, exec, hyprlock"
          "$mainMod, M, exit"
          "$mainMod, F, fullscreen"
          ''$mainMod SHIFT, S, exec, grim -l 0 -g "$(slurp)" - | wl-copy''

          # Moving focus with hjkl
          "$mainMod, H, movefocus, l"
          "$mainMod, L, movefocus, r"
          "$mainMod, K, movefocus, u"
          "$mainMod, J, movefocus, d"

          # Switch workspaces with mainMod + [0-9]
          "$mainMod, 1, workspace, 1"
          "$mainMod, 2, workspace, 2"
          "$mainMod, 3, workspace, 3"
          "$mainMod, 4, workspace, 4"
          "$mainMod, 5, workspace, 5"
          "$mainMod, 6, workspace, 6"
          "$mainMod, 7, workspace, 7"
          "$mainMod, 8, workspace, 8"
          "$mainMod, 9, workspace, 9"
          "$mainMod, 0, workspace, 10"

          # Move active window to a workspace with mainMod + SHIFT + [0-9]
          "$mainMod SHIFT, 1, movetoworkspace, 1"
          "$mainMod SHIFT, 2, movetoworkspace, 2"
          "$mainMod SHIFT, 3, movetoworkspace, 3"
          "$mainMod SHIFT, 4, movetoworkspace, 4"
          "$mainMod SHIFT, 5, movetoworkspace, 5"
          "$mainMod SHIFT, 6, movetoworkspace, 6"
          "$mainMod SHIFT, 7, movetoworkspace, 7"
          "$mainMod SHIFT, 8, movetoworkspace, 8"
          "$mainMod SHIFT, 9, movetoworkspace, 9"
          "$mainMod SHIFT, 0, movetoworkspace, 10"

          # Example special workspace (scratchpad)
          "$mainMod, S, togglespecialworkspace, magic"
          # Allows you to send things to the scratchpad
          "ALT SHIFT, S, movetoworkspace, special:magic"

          # Scroll through existing workspaces with mainMod + scroll
          "$mainMod, mouse_down, workspace, e+1"
          "$mainMod, mouse_up, workspace, e-1"

        ];
        bindel = [
          # Laptop multimedia keys for volume and LCD brightness
          ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
          ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
          ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
          ",XF86MonBrightnessUp, exec, brightnessctl s 10%+"
          ",XF86MonBrightnessDown, exec, brightnessctl s 10%-"
        ];

        bindl = [
          # Requires playerctl
          ", XF86AudioNext, exec, playerctl next"
          ", XF86AudioPause, exec, playerctl play-pause"
          ", XF86AudioPlay, exec, playerctl play-pause"
          ", XF86AudioPrev, exec, playerctl previous"
        ];

        ## WINDOWS & WORKSPACES
        # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more
        # See https://wiki.hyprland.org/Configuring/Workspace-Rules/ for workspace rules

        # Example windowrule v1
        # windowrule = float, ^(kitty)$

        # Example windowrule v2
        # windowrulev2 = float,class:^(kitty)$,title:^(kitty)$

        # Ignore maximize requests from apps. You'll probably like this.
        windowrulev2 = [
          "suppressevent maximize, class:.*"

          # Fix some dragging issues with XWayland
          "nofocus,class:^$,title:^$,xwayland:2,floating:1,fullscreen:0,pinned:0"
        ];
      };
      # Thing I need to use unstable for this to work
      # package = inputs.hyprland.packages.${pkgs.system}.hyprland;
      extraConfig = ''
        ###################
        ### MY PROGRAMS ###
        ###################

        # See https://wiki.hyprland.org/Configuring/Keywords/
        # Set programs that you use
        # $fileManager = dolphin


        #################
        ### AUTOSTART ###
        #################

        # Autostart necessary processes (like notifications daemons, status bars, etc.)
        # Or execute your favorite apps at launch like this:

        # exec-once = $terminal
        # exec-once = nm-applet &
        # exec-once = waybar & hyprpaper & firefox


        ###################
        ### KEYBINDINGS ###
        ###################

        # See https://wiki.hyprland.org/Configuring/Keywords/

        # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
        # bind = $mainMod, V, togglefloating,
        # TODO: Figure out what these do
        # bind = $mainMod, P, pseudo, # dwindle
        # bind = $mainMod, J, togglesplit, # dwindle


        # Move/resize windows with mainMod + LMB/RMB and dragging
        bindm = $mainMod, mouse:272, movewindow
        bindm = $mainMod, mouse:273, resizewindow
      '';
    };
  };
}
