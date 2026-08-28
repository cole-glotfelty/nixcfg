{ config, lib, pkgs, inputs, ... }:

with lib;
let
  cfg = config.features.desktop.waybar;
  colors = config.features.style.colors.palette.dark;

  weatherScript = pkgs.writeShellScript "waybar-weather" ''
    response=$(${pkgs.curl}/bin/curl -sf --max-time 10 "wttr.in/?format=j1&m" 2>/dev/null)
    if [ -z "$response" ]; then
      echo '{"text":"? N/A","tooltip":"Weather unavailable"}'
      exit 0
    fi

    # Build colored Pango spans for nf-weather-* icons (U+E300 range)
    s() { printf "<span color='%s'>$(printf "$2")</span>" "$1"; }
    span_sunny=$(s     '#${colors.yellow}' '\ue30d')       # yellow   – nf-weather-day_sunny
    span_pcloudy=$(s   '#${colors.fg}' '\ue302')           # gray     – nf-weather-day_cloudy
    span_cloudy=$(s    '#${colors.fg}' '\ue312')           # gray     – nf-weather-cloudy
    span_fog=$(s       '#${colors.fgGutter}' '\ue313')     # dim      – nf-weather-fog
    span_drizzle=$(s   '#${colors.cyan}' '\ue309')         # lt blue  – nf-weather-day_rain
    span_rain=$(s      '#${colors.blue}' '\ue318')         # blue     – nf-weather-rain
    span_pouring=$(s   '#${colors.blue}' '\ue319')         # blue     – nf-weather-showers
    span_snow=$(s      '#${colors.brightWhite}' '\ue31a')  # white    – nf-weather-snow
    span_snowflake=$(s '#${colors.brightWhite}' '\ue31f')  # white    – nf-weather-snowflake_cold
    span_blizzard=$(s  '#${colors.brightWhite}' '\ue31b')  # white    – nf-weather-snow_wind
    span_hail=$(s      '#${colors.cyan}' '\ue31e')         # icy blue – nf-weather-hail
    span_sleet=$(s     '#${colors.teal}' '\ue316')         # teal     – nf-weather-rain_mix
    span_tstorm=$(s    '#${colors.magenta}' '\ue31d')      # purple   – nf-weather-thunderstorm
    span_lightning=$(s '#${colors.magenta}' '\ue315')      # purple   – nf-weather-lightning

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
        (if   $temp >= 30 then "#${colors.red}"
         elif $temp >= 20 then "#${colors.orange}"
         elif $temp >= 10 then "#${colors.brightWhite}"
         elif $temp >= 0  then "#${colors.cyan}"
         else "#${colors.teal}" end) as $tc |
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
      if [ "$pct" -ge 80 ]; then color="#${colors.red}"
      elif [ "$pct" -ge 60 ]; then color="#${colors.orange}"
      elif [ "$pct" -ge 40 ]; then color="#${colors.yellow}"
      else color="#${colors.fg}"; fi
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

    if [ -f /tmp/wb-sysinfo-compact ]; then
      text="cpu $cpu_s | ram $ram_s | disk $disk_s"
    else
      text="$cpu_s | $ram_s | $disk_s"
    fi

    ${pkgs.jq}/bin/jq -cn \
      --arg text "$text" \
      --arg tooltip "CPU   $cpu%
RAM   ''${mem_used}G / ''${mem_total}G
Swap  ''${swap_used}G / ''${swap_total}G
Disk  ''${disk_free}G free" \
      '{text: $text, tooltip: $tooltip}'
  '';

  fcitxScript = pkgs.writeShellScript "waybar-fcitx5" ''
    im=$(${pkgs.fcitx5}/bin/fcitx5-remote -n 2>/dev/null)
    if [ -z "$im" ]; then
      # No input context focused yet — check if fcitx5 is actually running
      ${pkgs.fcitx5}/bin/fcitx5-remote > /dev/null 2>&1
      rc=$?
      if [ $rc -ne 1 ] && [ $rc -ne 2 ]; then
        ${pkgs.jq}/bin/jq -cn '{text: "", tooltip: "FCITX5 not running"}'
        exit 0
      fi
      im="keyboard-us"
    fi

    case "$im" in
      keyboard-us)  label="EN" ;;
      keyboard-*)   label=$(echo "''${im#keyboard-}" | tr '[:lower:]' '[:upper:]') ;;
      pinyin)       label="拼" ;;
      skk|mozc)     label="あ" ;;
      *)            label="$im" ;;
    esac

    ${pkgs.jq}/bin/jq -cn \
      --arg text "$label" \
      --arg tooltip "Input method: $im" \
      '{text: $text, tooltip: $tooltip}'
  '';

  fcitxCycle = pkgs.writeShellScript "waybar-fcitx5-cycle" ''
    ims=(keyboard-us pinyin mozc)
    current=$(${pkgs.fcitx5}/bin/fcitx5-remote -n 2>/dev/null)
    for i in "''${!ims[@]}"; do
      if [ "''${ims[$i]}" = "$current" ]; then
        next=$(( (i + 1) % ''${#ims[@]} ))
        ${pkgs.fcitx5}/bin/fcitx5-remote -s "''${ims[$next]}"
        pkill -SIGRTMIN+9 waybar
        exit 0
      fi
    done
    ${pkgs.fcitx5}/bin/fcitx5-remote -s "''${ims[0]}"
    pkill -SIGRTMIN+9 waybar
  '';

  sysToggle = pkgs.writeShellScript "waybar-sysinfo-toggle" ''
    if [ -f /tmp/wb-sysinfo-compact ]; then
      rm /tmp/wb-sysinfo-compact
    else
      touch /tmp/wb-sysinfo-compact
    fi
    pkill -SIGRTMIN+8 waybar
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
      updateInterval = 604800;  # Weekly (7 days)
      skipAfterBoot = true;
      updateLockFile = false;
    };

    programs.waybar = {
      enable = true;
      # Let systemd own a single waybar instance, started with graphical-session.target
      # (Hyprland activates this via systemd.variables = ["--all"]). Prevents the
      # duplicate instances that arise from launching waybar manually per-monitor.
      systemd.enable = true;
      settings = mkDefault {
        mainBar = {
          height = 30;
          spacing = 4;

          modules-left = [ "idle_inhibitor" "hyprland/workspaces" "mpd" ];
          modules-center = [ "clock" ];
          modules-right = [
            "custom/weather"
            "custom/sysinfo"
            # "custom/nix-updates" HACK: This needs to be resolved in the future with a way that doesn't crash my PC
            "network"
            "pulseaudio"
            "custom/fcitx5"
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
            signal = 8;
            on-click = "${sysToggle}";
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

          "custom/fcitx5" = {
            exec = "${fcitxScript}";
            interval = 1;
            return-type = "json";
            signal = 9;
            on-click = "${fcitxCycle}";
            on-click-right = "${pkgs.fcitx5}/bin/fcitx5-configtool";
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

          "tray" = { spacing = 10; ignored-addresses = [ "org.fcitx.Fcitx5" ]; };
        };
      };

      style = mkDefault ''
        * {
          font-family: "FiraCode Nerd Font", "FiraCode Nerd Font Mono", sans-serif;
          font-size: 13px;
          font-weight: 700;
          border: none;
          border-radius: 0;
          min-height: 0;
        }

        window#waybar {
          background: transparent;
        }

        #waybar {
          background-color: #${colors.bg};
          color: #${colors.fg};
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
        #custom-fcitx5,
        #custom-nix-updates,
        #network,
        #pulseaudio,
        #battery,
        #tray {
          background-color: #${colors.bgDark};
          color: #${colors.fg};
          padding: 4px 12px;
          margin: 4px 3px;
          border-radius: 8px;
          border: 1px solid #${colors.comment};
        }

        /* ── Left ── */

        #idle_inhibitor {
          font-size: 20px;
          color: #${colors.blue};
          padding-left: 7px;
        }

        #idle_inhibitor:hover {
          background: #${colors.comment};
          color: #${colors.fg};
        }

        #idle_inhibitor.activated {
          color: #${colors.green};
        }

        /* Workspaces: plain text, color-only active indicator */
        #workspaces {
          background-color: #${colors.bgDark};
          border: 1px solid #${colors.comment};
          padding: 0px 4px;
        }

        #workspaces button {
          color: #${colors.comment};
          background: transparent;
          border: none;
          padding: 2px 5px;
          margin: 0px 1px;
          font-size: 13px;
          font-weight: 700;
        }

        #workspaces button.active {
          color: #${colors.brightWhite};
          font-weight: 700;
        }

        #workspaces button:hover {
          color: #${colors.fg};
          background: transparent;
        }

        #workspaces button.urgent {
          color: #${colors.red};
          background-color: ${lib.rgba colors.red 0.15};
          border-color: #${colors.red};
        }

        /* MPD now-playing */
        #mpd {
          color: #${colors.magenta};
        }

        #mpd.playing {
          color: #${colors.green};
        }

        #mpd.paused {
          color: #${colors.yellow};
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
          color: #${colors.fg};
          font-weight: 700;
        }

        /* ── Right ── */

        #custom-fcitx5 {
          color: #${colors.cyan};
          font-weight: 700;
        }

        #custom-weather {
          color: #${colors.yellow};
        }

        #custom-sysinfo {
          color: #${colors.fg};
          font-family: "FiraCode Nerd Font", monospace;
        }

        #custom-nix-updates {
          color: #${colors.fg};
        }

        #custom-nix-updates.has-updates {
          color: #${colors.red};
        }

        #network {
          color: #${colors.green};
        }

        #network.disconnected {
          color: #${colors.red};
        }

        #pulseaudio {
          color: #${colors.blue};
        }

        #pulseaudio.muted {
          color: #${colors.red};
        }

        #battery {
          color: #${colors.green};
        }

        #battery.charging {
          color: #${colors.cyan};
        }

        #battery.warning:not(.charging) {
          background-color: ${lib.rgba colors.yellow 0.2};
          color: #${colors.yellow};
        }

        #battery.critical:not(.charging) {
          background-color: ${lib.rgba colors.red 0.2};
          color: #${colors.red};
          animation: blink 0.5s linear infinite alternate;
        }

        @keyframes blink {
          to { background-color: ${lib.rgba colors.red 0.05}; }
        }

        #tray {
          padding: 4px 8px;
        }

        #tray.empty {
          min-width: 0;
          padding: 0;
          margin: 0;
          border: none;
          background: transparent;
        }

        #tray > .passive {
          -gtk-icon-effect: dim;
        }

        #tray > .needs-attention {
          -gtk-icon-effect: highlight;
          background-color: ${lib.rgba colors.red 0.3};
        }
      '';
    };
  };
}
