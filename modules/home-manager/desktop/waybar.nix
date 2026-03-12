{ config, lib, pkgs, inputs, ... }:

with lib;
let
  cfg = config.features.desktop.waybar;

  weatherScript = pkgs.writeShellScript "waybar-weather" ''
    response=$(${pkgs.curl}/bin/curl -sf --max-time 10 "wttr.in/?format=j1&m" 2>/dev/null)
    if [ -z "$response" ]; then
      echo '{"text":"? N/A","tooltip":"Weather unavailable"}'
      exit 0
    fi

    # Build colored Pango spans for nf-weather-* icons (U+E300 range)
    s() { printf "<span color='%s'>$(printf "$2")</span>" "$1"; }
    span_sunny=$(s     '#e0af68' '\ue30d')   # yellow   – nf-weather-day_sunny
    span_pcloudy=$(s   '#a9b1d6' '\ue302')   # gray     – nf-weather-day_cloudy
    span_cloudy=$(s    '#a9b1d6' '\ue312')   # gray     – nf-weather-cloudy
    span_fog=$(s       '#565f89' '\ue313')   # dim      – nf-weather-fog
    span_drizzle=$(s   '#7dcfff' '\ue309')   # lt blue  – nf-weather-day_rain
    span_rain=$(s      '#7aa2f7' '\ue318')   # blue     – nf-weather-rain
    span_pouring=$(s   '#7aa2f7' '\ue319')   # blue     – nf-weather-showers
    span_snow=$(s      '#c0caf5' '\ue31a')   # white    – nf-weather-snow
    span_snowflake=$(s '#c0caf5' '\ue31f')   # white    – nf-weather-snowflake_cold
    span_blizzard=$(s  '#c0caf5' '\ue31b')   # white    – nf-weather-snow_wind
    span_hail=$(s      '#7dcfff' '\ue31e')   # icy blue – nf-weather-hail
    span_sleet=$(s     '#73daca' '\ue316')   # teal     – nf-weather-rain_mix
    span_tstorm=$(s    '#bb9af7' '\ue31d')   # purple   – nf-weather-thunderstorm
    span_lightning=$(s '#bb9af7' '\ue315')   # purple   – nf-weather-lightning

    echo "$response" | ${pkgs.jq}/bin/jq -c \
      --arg sunny     "$span_sunny"     \
      --arg pcloudy   "$span_pcloudy"   \
      --arg cloudy    "$span_cloudy"    \
      --arg fog       "$span_fog"       \
      --arg drizzle   "$span_drizzle"   \
      --arg rain      "$span_rain"      \
      --arg pouring   "$span_pouring"   \
      --arg snow      "$span_snow"      \
      --arg snowflake "$span_snowflake" \
      --arg blizzard  "$span_blizzard"  \
      --arg sleet     "$span_sleet"     \
      --arg hail      "$span_hail"      \
      --arg tstorm    "$span_tstorm"    \
      --arg lightning "$span_lightning" \
      '
        .current_condition[0] as $c |
        (.nearest_area[0].areaName[0].value) as $loc |
        ($c.weatherCode | tonumber) as $code |
        ($c.temp_C | tonumber) as $temp |
        (if   $code == 113 then $sunny
         elif $code == 116 then $pcloudy
         elif $code == 119 or $code == 122 then $cloudy
         elif $code == 143 or $code == 248 or $code == 260 then $fog
         elif $code == 176 or $code == 263 or $code == 266 or $code == 293 or $code == 296 or $code == 353 then $drizzle
         elif $code == 299 or $code == 302 or $code == 305 or $code == 308 or $code == 356 then $rain
         elif $code == 359 then $pouring
         elif $code == 179 or $code == 323 or $code == 326 or $code == 329 or $code == 332 or $code == 368 then $snow
         elif $code == 335 or $code == 338 or $code == 371 then $snowflake
         elif $code == 227 or $code == 230 then $blizzard
         elif $code == 350 or $code == 362 or $code == 365 or $code == 374 or $code == 377 then $hail
         elif $code == 182 or $code == 185 or $code == 281 or $code == 284 or $code == 311 or $code == 314 or $code == 317 or $code == 320 then $sleet
         elif $code == 200 or $code == 386 or $code == 389 then $tstorm
         elif $code == 392 or $code == 395 then $lightning
         else $sunny end) as $icon |
        (if   $temp >= 30 then "#f7768e"
         elif $temp >= 20 then "#ff9e64"
         elif $temp >= 10 then "#c0caf5"
         elif $temp >= 0  then "#7dcfff"
         else "#73daca" end) as $tc |
        {
          text: "\($icon)  <span color=\"\($tc)\">\($c.temp_C)°C</span>",
          tooltip: "\($c.weatherDesc[0].value)\n\($c.temp_C)°C (feels like \($c.FeelsLikeC)°C)\nHumidity: \($c.humidity)%\nLocation: \($loc)"
        }
      '
  '';

  sysScript = pkgs.writeShellScript "waybar-sysinfo" ''
    read _ u n s id io ir si st _ < /proc/stat
    if read pu pn ps pid pio pir psi pst < /tmp/wb-cpu 2>/dev/null; then
      dt=$(( (u+n+s+id+io+ir+si+st) - (pu+pn+ps+pid+pio+pir+psi+pst) ))
      di=$(( id - pid ))
      cpu=$(( dt > 0 ? (dt-di)*100/dt : 0 ))
    else
      cpu=0
    fi
    printf '%s %s %s %s %s %s %s %s\n' "$u" "$n" "$s" "$id" "$io" "$ir" "$si" "$st" > /tmp/wb-cpu

    span() {
      local pct=$1 text=$2 color
      [ "$pct" -ge 80 ] && color="#f7768e" || { [ "$pct" -ge 60 ] && color="#e0af68" || color="#9ece6a"; }
      printf '<span color="%s">%s</span>' "$color" "$text"
    }

    read mem_used mem_total swap_used swap_total mem_pct < <(
      awk '/^MemTotal:/{mt=$2} /^MemAvailable:/{ma=$2}
           /^SwapTotal:/{st=$2} /^SwapFree:/{sf=$2}
           END{u=(mt-ma)/1048576; printf "%.1f %.1f %.1f %.1f %d\n",
             u, mt/1048576, (st-sf)/1048576, st/1048576, int((mt-ma)*100/mt)}' \
        /proc/meminfo
    )

    read disk_free disk_pct < <(
      df -BG / | awk 'NR==2{gsub(/[G%]/,""); print $4, $5}'
    )

    cpu_s=$(span "$cpu" "$cpu%")
    ram_s=$(span "$mem_pct" "''${mem_used}G")
    disk_s=$(span "$disk_pct" "''${disk_free}G")

    ${pkgs.jq}/bin/jq -cn \
      --arg text "cpu $cpu_s | ram $ram_s | disk $disk_s" \
      --arg tooltip "CPU   $cpu%
RAM   ''${mem_used}G / ''${mem_total}G
Swap  ''${swap_used}G / ''${swap_total}G
Disk  ''${disk_free}G free" \
      '{text: $text, tooltip: $tooltip}'
  '';

  nixUpdatesExec = pkgs.writeShellScript "nix-updates-waybar" ''
    ${config.home.homeDirectory}/.config/waybar/scripts/update-checker | \
      ${pkgs.jq}/bin/jq -c 'if .text == "0" then {text: ""} else . + {class: .alt} end'
  '';

in
{
  imports = [ inputs.waybar-nixos-updates.homeManagerModules.default ];
  options.features.desktop.waybar = {
    enable = mkEnableOption (lib.mdDoc ''
      Waybar status bar for Wayland compositors.

      Features:
      - Nix logo button (opens wlogout)
      - Hyprland workspaces as colored dots/pills
      - Now playing via MPD
      - Date/time in center
      - Weather (emoji + temp)
      - Nixpkgs update count
      - Network, audio, battery, system tray

      Designed for: Hyprland
      Dependencies: MPD (optional), PulseAudio
    '');
  };

  config = mkIf cfg.enable {
    # waybar-nixos-updates hardcodes NIXOS_CONFIG_PATH="$HOME/.config/nixos" in its
    # script body, overwriting the wrapper's export. Symlink to work around the bug.
    home.file.".config/nixos" = {
      source = config.lib.file.mkOutOfStoreSymlink (builtins.toString config.custom.paths.nixcfg);
    };

    programs.waybar-nixos-updates = {
      enable = true;
      nixosConfigPath = builtins.toString config.custom.paths.nixcfg;
      updateInterval = 3600;
      skipAfterBoot = true;
      updateLockFile = false;
    };

    # NOTE: Colors match Hyprland's cyan/teal gradient: rgba(33ccffee) rgba(00ff99ee)
    # TODO: Replace with system-wide color/theme management when implemented.
    programs.waybar = {
      enable = true;
      settings = mkDefault {
        mainBar = {
          height = 30;
          spacing = 4;

          modules-left = [ "idle_inhibitor" "hyprland/workspaces" "mpd" ];
          modules-center = [ "clock" ];
          modules-right = [
            "custom/weather"
            "custom/sysinfo"
            "custom/nix-updates"
            "network"
            "pulseaudio"
            "battery"
            "battery#bat2"
            "tray"
          ];

          "idle_inhibitor" = {
            format = "{icon}";
            format-icons = {
              activated = "󱄅";
              deactivated = "󱄅";
            };
            tooltip-format-activated = "Sleep inhibited";
            tooltip-format-deactivated = "Click to inhibit sleep";
          };

          "hyprland/workspaces" = {
            format = "{icon}";
            on-click = "activate";
            sort-by-number = true;
            format-icons = {
              "1" = "I";
              "2" = "II";
              "3" = "III";
              "4" = "IV";
              "5" = "V";
              "6" = "VI";
              "7" = "VII";
              "8" = "VIII";
              "9" = "IX";
              "10" = "X";
            };
          };

          "mpd" = {
            format = "{stateIcon} {artist} - {title}";
            format-stopped = "";
            format-disconnected = "";
            max-length = 50;
            interval = 5;
            state-icons = {
              paused = "󰏤";
              playing = "󰐊";
            };
            tooltip-format = "{artist} - {album}\n{title}\n{elapsedTime:%M:%S} / {totalTime:%M:%S}";
            tooltip-format-disconnected = "MPD disconnected";
            on-click = "${pkgs.mpc}/bin/mpc toggle";
            on-click-right = "${config.custom.defaults.terminal} -e rmpc";
          };

          "clock" = {
            format = "{:%A, %B %d %H:%M}";
            tooltip-format = ''
              <big>{:%Y %B}</big>
              <tt><small>{calendar}</small></tt>'';
          };

          "custom/weather" = {
            exec = "${weatherScript}";
            interval = 1800;
            format = "{}";
            return-type = "json";
          };

          "custom/sysinfo" = {
            exec = "${sysScript}";
            interval = 3;
            return-type = "json";
          };

          "custom/nix-updates" = {
            exec = "${nixUpdatesExec}";
            signal = 12;
            on-click = "${config.home.homeDirectory}/.config/waybar/scripts/update-checker toggle";
            on-click-right = "rm ~/.cache/nix-update-last-run";
            interval = 3600;
            tooltip = true;
            hide-empty-text = true;
            return-type = "json";
            format = "{} {icon}";
            format-icons = {
              has-updates = "";
              updating = "󰦗";
              updated = "";
              disabled = "󱂱";
              error = "";
            };
          };

          "network" = {
            format-wifi = "{essid} {icon}";
            format-alt = "{essid} ({signalStrength}%) {icon}";
            format-ethernet = "{ipaddr} 󰈀";
            format-linked = "{ifname} (No IP) 󰤫";
            format-disconnected = "󰤮 Disconnected";
            tooltip-format = "{ifname} via {gwaddr} - Signal: {signalStrength}%";
            format-icons = [ "󰤫" "󰤟" "󰤢" "󰤥" "󰤨" ];
            on-click-right = "networkmanager_dmenu";
          };

          "pulseaudio" = {
            format = "{volume}% {icon}";
            format-bluetooth = "{volume}% 󰂰";
            format-bluetooth-muted = "󰂲";
            format-muted = "󰸈";
            format-icons = {
              headphone = "󰋋";
              hands-free = "󰋎";
              headset = "󰋎";
              phone = "󰏲";
              portable = "󰓃";
              car = "󰄋";
              default = [ "󰕿" "󰖀" "󰕾" ];
            };
            on-click = "pavucontrol";
          };

          "battery" = {
            states = {
              warning = 30;
              critical = 15;
            };
            format = "{capacity}% {icon}";
            format-charging = "{capacity}% 󰂄";
            format-plugged = "{capacity}% 󰚥";
            format-alt = "{time} {icon}";
            format-icons = [ "󰁻" "󰁽" "󰁿" "󰂁" "󰁹" ];
          };

          "battery#bat2" = { bat = "BAT2"; };

          "tray" = { spacing = 10; };
        };
      };

      style = mkDefault ''
        /* Tokyo Night */
        /* bg: #1a1b26  surface: #1f2335  surface2: #24283b  border: #414868 */
        /* fg: #c0caf5  blue: #7aa2f7  cyan: #7dcfff  green: #9ece6a        */
        /* yellow: #e0af68  red: #f7768e  purple: #bb9af7  teal: #73daca     */

        * {
          font-family: "FiraCode Nerd Font", "FiraCode Nerd Font Mono", sans-serif;
          font-size: 13px;
          font-weight: 500;
          border: none;
          border-radius: 0;
          min-height: 0;
        }

        window#waybar {
          background: transparent;
        }

        #waybar {
          background-color: #1a1b26;
          color: #c0caf5;
          margin: 8px 12px 0px 12px;
          border-radius: 12px;
          box-shadow: 0 4px 12px rgba(0, 0, 0, 0.5);
          padding: 0px 8px;
        }

        /* Base module style */
        #workspaces,
        #mpd,
        #clock,
        #idle_inhibitor,
        #custom-weather,
        #custom-sysinfo,
        #custom-nix-updates,
        #network,
        #pulseaudio,
        #battery,
        #tray {
          background-color: #1f2335;
          color: #c0caf5;
          padding: 4px 12px;
          margin: 4px 3px;
          border-radius: 8px;
          border: 1px solid #414868;
        }

        /* ── Left ── */

        #idle_inhibitor {
          font-size: 20px;
          color: #7aa2f7;
          background: #24283b;
          padding-left: 7px;
        }

        #idle_inhibitor:hover {
          background: #414868;
          color: #c0caf5;
        }

        #idle_inhibitor.activated {
          color: #9ece6a;
        }

        /* Workspaces: plain text, color-only active indicator */
        #workspaces {
          background-color: #1f2335;
          border: 1px solid #414868;
          padding: 0px 4px;
        }

        #workspaces button {
          color: #414868;
          background: transparent;
          border: none;
          padding: 2px 5px;
          margin: 0px 1px;
          font-size: 13px;
          font-weight: 500;
        }

        #workspaces button.active {
          color: #7aa2f7;
          font-weight: 700;
        }

        #workspaces button:hover {
          color: #c0caf5;
          background: transparent;
        }

        #workspaces button.urgent {
          color: #f7768e;
          background-color: rgba(247, 118, 142, 0.15);
          border-color: #f7768e;
        }

        /* MPD now-playing */
        #mpd {
          color: #bb9af7;
        }

        #mpd.playing {
          color: #9ece6a;
        }

        #mpd.paused {
          color: #e0af68;
        }

        /* Hide MPD when stopped or disconnected */
        #mpd.disconnected,
        #mpd.stopped {
          padding: 0;
          margin: 0;
          min-width: 0;
          border: none;
          background-color: transparent;
          font-size: 0;
        }

        /* ── Center ── */

        #clock {
          color: #c0caf5;
          font-weight: 700;
        }

        /* ── Right ── */

        #custom-weather {
          color: #e0af68;
        }

        #custom-sysinfo {
          color: #c0caf5;
          font-family: "FiraCode Nerd Font", monospace;
        }

        #custom-nix-updates {
          color: #c0caf5;
        }

        #custom-nix-updates.has-updates {
          color: #f7768e;
        }

        #network {
          color: #9ece6a;
        }

        #network.disconnected {
          color: #f7768e;
        }

        #pulseaudio {
          color: #7aa2f7;
        }

        #pulseaudio.muted {
          color: #f7768e;
        }

        #battery {
          color: #9ece6a;
        }

        #battery.charging {
          color: #7dcfff;
        }

        #battery.warning:not(.charging) {
          background-color: rgba(224, 175, 104, 0.2);
          color: #e0af68;
        }

        #battery.critical:not(.charging) {
          background-color: rgba(247, 118, 142, 0.2);
          color: #f7768e;
          animation: blink 0.5s linear infinite alternate;
        }

        @keyframes blink {
          to { background-color: rgba(247, 118, 142, 0.05); }
        }

        #tray {
          padding: 4px 8px;
        }

        #tray > .passive {
          -gtk-icon-effect: dim;
        }

        #tray > .needs-attention {
          -gtk-icon-effect: highlight;
          background-color: rgba(247, 118, 142, 0.3);
        }
      '';
    };
  };
}
