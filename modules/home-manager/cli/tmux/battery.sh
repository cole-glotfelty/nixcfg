#!/bin/bash
# Battery percent + a Nerd Font glyph that tracks charge level.
raw=$(pmset -g batt 2>/dev/null)
pct=$(printf '%s' "$raw" | grep -Eo '[0-9]+%' | head -1 | tr -d '%')
[ -z "$pct" ] && exit 0
if printf '%s' "$raw" | grep -q 'AC Power'; then g=''
elif [ "$pct" -ge 80 ]; then g=''
elif [ "$pct" -ge 60 ]; then g=''
elif [ "$pct" -ge 40 ]; then g=''
elif [ "$pct" -ge 20 ]; then g=''
else g=''
fi
printf '%s %s%%' "$g" "$pct"
