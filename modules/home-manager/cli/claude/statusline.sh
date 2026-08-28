#!/usr/bin/env bash
# Claude Code statusline
# Reads the statusline JSON on stdin, prints one colored line.

input="$(cat)"

# --- colors -----------------------------------------------------------
RESET=$'\033[0m'
BOLD=$'\033[1m'
DIM=$'\033[2m'
RED=$'\033[31m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
BLUE=$'\033[34m'
MAGENTA=$'\033[35m'
CYAN=$'\033[36m'
GRAY=$'\033[90m'
BRED=$'\033[91m'
BGREEN=$'\033[92m'
BYELLOW=$'\033[93m'
BBLUE=$'\033[94m'
ORANGE=$'\033[38;5;208m'
SEP="${GRAY} │ ${RESET}"

get() { printf '%s' "$input" | jq -r "$1" 2>/dev/null; }

# --- vim mode -----------------------------------------------------------
vim_mode="$(get '.vim.mode // empty')"
vim_seg=""
mode_color="$GRAY"
if [ -n "$vim_mode" ]; then
  case "$vim_mode" in
    NORMAL)       mode_color="$BBLUE";  vim_seg="${mode_color}NOR${RESET}" ;;
    INSERT)       mode_color="$BGREEN"; vim_seg="${mode_color}INS${RESET}" ;;
    VISUAL|"VISUAL LINE") mode_color="$MAGENTA"; vim_seg="${mode_color}VIS${RESET}" ;;
    *)            mode_color="$GRAY";   vim_seg="${mode_color}${vim_mode}${RESET}" ;;
  esac
fi

# --- model + effort -----------------------------------------------------
model="$(get '.model.display_name // .model.id // "?"')"
model_seg="${CYAN}${model}${RESET}"

effort="$(get '.effort.level // empty')"
effort_seg=""
effort_color="$GRAY"
if [ -n "$effort" ]; then
  case "$effort" in
    low)    effort_color="$GREEN";   effort_seg="${effort_color}low${RESET}" ;;
    medium) effort_color="$YELLOW";  effort_seg="${effort_color}med${RESET}" ;;
    high)   effort_color="$ORANGE";  effort_seg="${effort_color}high${RESET}" ;;
    xhigh)  effort_color="$RED";     effort_seg="${effort_color}xhigh${RESET}" ;;
    max)    effort_color="$MAGENTA"; effort_seg="${effort_color}max${RESET}" ;;
    *)      effort_color="$GRAY";    effort_seg="${effort_color}${effort}${RESET}" ;;
  esac
fi

# --- thinking / fast mode icons ------------------------------------------
# nf-fa-lightbulb (U+F0EB) / nf-fa-bolt (U+F0E7)
thinking="$(get '.thinking.enabled // false')"
fast="$(get '.fast_mode // false')"
icons=""
[ "$thinking" = "true" ] && icons="${icons}${effort_color}${RESET}"
[ "$fast" = "true" ] && icons="${icons}${effort_color}${RESET}"

# --- context usage graph -------------------------------------------------
used_pct="$(get '.context_window.used_percentage // empty')"
ctx_seg=""
if [ -n "$used_pct" ]; then
  used_int=$(printf '%.0f' "$used_pct" 2>/dev/null || echo 0)
  filled=$(( used_int / 10 ))
  [ "$filled" -gt 10 ] && filled=10
  [ "$filled" -lt 0 ] && filled=0
  empty=$(( 10 - filled ))
  bar="$(printf '█%.0s' $(seq 1 "$filled" 2>/dev/null))$(printf '░%.0s' $(seq 1 "$empty" 2>/dev/null))"
  if [ "$used_int" -ge 80 ]; then bar_color="$BRED"
  elif [ "$used_int" -ge 50 ]; then bar_color="$BYELLOW"
  else bar_color="$BGREEN"
  fi
  ctx_seg="${bar_color}${bar} ${used_int}%${RESET}"
fi

# --- working dir / git repo + diff +/- -------------------------------------
dir="$(get '.workspace.current_dir // .cwd // empty')"
dir_seg=""
git_seg=""
if [ -n "$dir" ]; then
  if git -C "$dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    repo="$(basename "$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null)")"
    branch="$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null)"
    dir_seg="${BLUE}${repo}${RESET}${GRAY}/${RESET}${YELLOW}${branch}${RESET}"

    stats="$( { git -C "$dir" --no-optional-locks diff --numstat 2>/dev/null; git -C "$dir" --no-optional-locks diff --cached --numstat 2>/dev/null; } | awk '{a+=$1; d+=$2} END{printf "%d %d", a+0, d+0}')"
    added="${stats%% *}"
    removed="${stats##* }"
    git_seg="${GREEN}+${added}${RESET}${GRAY}/${RESET}${RED}-${removed}${RESET}"
  else
    dir_seg="${BLUE}$(basename "$dir")${RESET}"
  fi
fi

# --- session cost -----------------------------------------------------------
cost="$(get '.cost.total_cost_usd // 0')"
cost_fmt="$(printf '%.4f' "$cost" 2>/dev/null || echo "0.0000")"
cost_seg="${GREEN}\$${cost_fmt}${RESET}"

# --- assemble ---------------------------------------------------------------
line=" "
[ -n "$vim_seg" ] && line="${line}${vim_seg}${SEP}"
if [ -n "$dir_seg" ]; then
  line="${line}${dir_seg}"
  [ -n "$git_seg" ] && line="${line} ${git_seg}"
  line="${line}${SEP}"
fi
line="${line}${model_seg}"
[ -n "$effort_seg" ] && line="${line}${SEP}${effort_seg}"
[ -n "$icons" ] && line="${line} ${icons}"
[ -n "$ctx_seg" ] && line="${line}${SEP}${ctx_seg}"
line="${line}${SEP}${cost_seg}"

printf '%s%s\n' "$line" "$RESET"
