{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.desktop.waybar;
in {
  options.features.desktop.waybar = {
    enable = mkEnableOption (lib.mdDoc ''
      Waybar status bar for Wayland compositors with comprehensive system monitoring.
      
      Features:
      - Hyprland workspace and window integration
      - System monitoring: CPU, memory, temperature, battery
      - Network status with WiFi/Ethernet details  
      - Audio control via PulseAudio
      - MPD music player integration
      - Power profile daemon integration
      - Backlight controls for laptops
      - System tray and custom power menu
      - Idle inhibitor toggle
      
      Designed for: Hyprland, supports dual battery setups
      Dependencies: PulseAudio, power-profiles-daemon, MPD (optional)
    '');
  };

  config = mkIf cfg.enable {
    # TODO: Rearrange modules, create new modules
    # TODO: Colors and CSS Themeing
    # NOTE: Current color scheme matches Hyprland's cyan/teal gradient.
    #       Revisit this when implementing system-wide color/theme management.
    programs.waybar = {
      enable = true;
      # package = (pkgs.waybar.overrideAttrs (oldAtts: {
      #   mesonFlags = oldAtts.mesonFlags ++ [ "-Dexperimental=true" ];
      # }));
      settings = mkDefault {
        mainBar = {
          height = 30;
          spacing = 4;
          modules-left =
            [ "hyprland/workspaces" "custom/media" ];
          modules-center = [ "hyprland/window" ];
          modules-right = [
            "mpd"
            "idle_inhibitor"
            "pulseaudio"
            "network"
            "power-profiles-daemon"
            "cpu"
            "memory"
            "temperature"
            "backlight"
            "battery"
            "battery#bat2"
            "clock"
            "tray"
            "custom/power"
          ];

          "mpd" = {
            format =
              "{stateIcon} {consumeIcon}{randomIcon}{repeatIcon}{singleIcon}{artist} - {album} - {title} ({elapsedTime:%M:%S}/{totalTime:%M:%S}) ⸨{songPosition}|{queueLength}⸩ {volume}% ";
            format-disconnected = "Disconnected ";
            format-stopped =
              "{consumeIcon}{randomIcon}{repeatIcon}{singleIcon}Stopped ";
            unknown-tag = "N/A";
            interval = 5;
            consume-icons = { on = " "; };
            random-icons = {
              off = ''<span color="#f53c3c"></span> '';
              on = " ";
            };
            repeat-icons = { on = " "; };
            single-icons = { on = "1 "; };
            state-icons = {
              paused = "";
              playing = "";
            };
            tooltip-format = "MPD (connected)";
            tooltip-format-disconnected = "MPD (disconnected)";
          };

          "idle_inhibitor" = {
            format = "{icon}";
            format-icons = {
              activated = "";
              deactivated = "";
            };
          };

          "pulseaudio" = {
            format = "{volume}% {icon}";
            format-bluetooth = "{volume}% {icon}";
            format-bluetooth-muted = "󰂲 {icon}";
            format-muted = "󰖁";
            format-icons = {
              headphone = "";
              hands-free = "";
              headset = "";
              phone = "";
              portable = "";
              car = "";
              default = [ "󰕿" "󰖀" "󰕾" ];
            };
            on-click = "pavucontrol";
          };

          "tray" = { spacing = 10; };

          "clock" = {
            format = "{:%b %e  %H:%M}";
            format-alt = "{:%A, %B %d  %H:%M:%S}";
            tooltip-format = ''
              <big>{:%Y %B}</big>
              <tt><small>{calendar}</small></tt>'';
          };

          "cpu" = {
            format = "{usage}% ";
            tooltip = false;
          };

          "memory" = { format = "{}% "; };

          "temperature" = {
            critical-threshold = 80;
            format = "{temperatureC}°C {icon}";
            format-icons = [ "" "" "" ];
          };

          "backlight" = {
            format = "{percent}% {icon}";
            format-icons = [ "" "" "" "" "" "" "" "" "" ];
          };

          "battery" = {
            states = {
              warning = 30;
              critical = 15;
            };
            format = "{capacity}% {icon}";
            format-full = "{capacity}% {icon}";
            format-charging = "{capacity}% ";
            format-plugged = "{capacity}% ";
            format-alt = "{time} {icon}";
            format-icons = [ "" "" "" "" "" ];
          };

          "battery#bat2" = { bat = "BAT2"; };

          "power-profiles-daemon" = {
            format = "{icon}";
            tooltip-format = ''
              Power profile: {profile}
              Driver: {driver}'';
            tooltip = true;
            format-icons = {
              default = "";
              performance = "";
              balanced = "";
              power-saver = "";
            };
          };

          "network" = {
            format-wifi = "{essid} ";
            format-ethernet = "{ipaddr}/{cidr} ";
            tooltip-format = "{ifname} via {gwaddr} ";
            format-linked = "{ifname} (No IP) ";
            format-disconnected = "Disconnected ⚠";
            format-alt = "{ifname}: {ipaddr}/{cidr}";
          };

          "custom/power" = {
            format = "⏻";
            on-click = "wlogout";
            tooltip = false;
          };
        };
      };

      style = mkDefault ''
        /* Floating Bar Rice - Hyprland Cyan/Teal Theme */
        /* Colors matching Hyprland's gradient: rgba(33ccffee) rgba(00ff99ee) */

        * {
          font-family: "JetBrainsMono Nerd Font", "Font Awesome 6 Free", sans-serif;
          font-size: 13px;
          font-weight: 500;
          border: none;
          border-radius: 0;
          min-height: 0;
        }

        /* Main bar styling - floating with rounded corners */
        window#waybar {
          background: transparent;
        }

        #waybar {
          background-color: rgba(26, 27, 38, 0.92);
          color: #cdd6f4;
          margin: 8px 12px 0px 12px;
          border-radius: 12px;
          border: 2px solid rgba(51, 204, 255, 0.3);
          box-shadow: 0 4px 8px rgba(0, 0, 0, 0.4);
          padding: 0px 8px;
        }

        /* Module styling */
        #workspaces,
        #window,
        #mpd,
        #idle_inhibitor,
        #pulseaudio,
        #network,
        #power-profiles-daemon,
        #cpu,
        #memory,
        #temperature,
        #backlight,
        #language,
        #battery,
        #clock,
        #tray,
        #custom-power,
        #custom-media {
          background-color: rgba(30, 30, 46, 0.6);
          color: #cdd6f4;
          padding: 4px 12px;
          margin: 4px 3px;
          border-radius: 8px;
          border: 1px solid rgba(51, 204, 255, 0.2);
        }

        /* Workspaces - gradient accent */
        #workspaces {
          padding: 0px 6px;
        }

        #workspaces button {
          padding: 4px 8px;
          color: #7aa2f7;
          background-color: transparent;
          border-radius: 6px;
          margin: 2px;
        }

        #workspaces button.active {
          background: linear-gradient(45deg, rgba(51, 204, 255, 0.4), rgba(0, 255, 153, 0.4));
          color: #ffffff;
          font-weight: 600;
          border: 1px solid rgba(51, 204, 255, 0.5);
        }

        #workspaces button:hover {
          background-color: rgba(51, 204, 255, 0.2);
          color: #ffffff;
        }

        #workspaces button.urgent {
          background-color: rgba(245, 60, 60, 0.6);
          color: #ffffff;
        }

        /* Window title - centered, subtle */
        #window {
          color: #a9b1d6;
          font-style: italic;
        }

        /* Clock - gradient highlight */
        #clock {
          background: linear-gradient(45deg, rgba(51, 204, 255, 0.3), rgba(0, 255, 153, 0.3));
          color: #ffffff;
          font-weight: 600;
          border: 1px solid rgba(51, 204, 255, 0.4);
        }

        /* Tray */
        #tray {
          padding: 4px 8px;
        }

        #tray > .passive {
          -gtk-icon-effect: dim;
        }

        #tray > .needs-attention {
          -gtk-icon-effect: highlight;
          background-color: rgba(245, 60, 60, 0.4);
        }

        /* System stats - color coding */
        #cpu {
          color: #7dcfff;
        }

        #memory {
          color: #bb9af7;
        }

        #temperature {
          color: #f7768e;
        }

        #temperature.critical {
          background-color: rgba(247, 118, 142, 0.4);
          color: #ffffff;
          font-weight: 600;
        }

        /* Battery states */
        #battery {
          color: #9ece6a;
        }

        #battery.charging {
          color: #33ccff;
        }

        #battery.warning:not(.charging) {
          background-color: rgba(255, 165, 0, 0.4);
          color: #ffffff;
        }

        #battery.critical:not(.charging) {
          background-color: rgba(245, 60, 60, 0.6);
          color: #ffffff;
          animation: blink 0.5s linear infinite alternate;
        }

        @keyframes blink {
          to {
            background-color: rgba(245, 60, 60, 0.3);
          }
        }

        /* Audio */
        #pulseaudio {
          color: #7aa2f7;
        }

        #pulseaudio.muted {
          color: #f7768e;
        }

        /* Network */
        #network {
          color: #9ece6a;
        }

        #network.disconnected {
          color: #f7768e;
        }

        /* Power profile daemon */
        #power-profiles-daemon {
          color: #e0af68;
        }

        #power-profiles-daemon.performance {
          background-color: rgba(247, 118, 142, 0.3);
          color: #f7768e;
        }

        #power-profiles-daemon.power-saver {
          background-color: rgba(158, 206, 106, 0.3);
          color: #9ece6a;
        }

        /* Backlight */
        #backlight {
          color: #e0af68;
        }

        /* MPD */
        #mpd {
          color: #bb9af7;
        }

        #mpd.disconnected,
        #mpd.stopped {
          color: #565f89;
        }

        #mpd.playing {
          color: #9ece6a;
        }

        #mpd.paused {
          color: #e0af68;
        }

        /* Idle inhibitor */
        #idle_inhibitor {
          color: #7aa2f7;
          padding: 4px 10px;
        }

        #idle_inhibitor.activated {
          background-color: rgba(247, 118, 142, 0.3);
          color: #f7768e;
        }

        /* Custom power button - gradient accent */
        #custom-power {
          background: linear-gradient(45deg, rgba(247, 118, 142, 0.3), rgba(237, 135, 150, 0.3));
          color: #f7768e;
          padding: 4px 10px;
          font-weight: 600;
        }

        #custom-power:hover {
          background: linear-gradient(45deg, rgba(247, 118, 142, 0.5), rgba(237, 135, 150, 0.5));
        }
      '';
    };
  };
}
