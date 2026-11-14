#!/usr/bin/env bash
# Claude Code status line: everything on a single line.
input=$(cat)
j() { printf '%s' "$input" | jq -r "$1"; }

cwd=$(j '.workspace.current_dir')
model=$(j '.model.display_name')
effort=$(j '.effort.level // empty')
fast=$(j '.fast_mode // false')
session=$(j '.session_name // empty')
remaining=$(j '.context_window.remaining_percentage // empty')
h5=$(j '.rate_limits.five_hour.used_percentage // empty')
h5_reset=$(j '.rate_limits.five_hour.resets_at // empty')
d7=$(j '.rate_limits.seven_day.used_percentage // empty')
d7_reset=$(j '.rate_limits.seven_day.resets_at // empty')

dir_display=${cwd/#$HOME/\~}
branch=""
if git -C "$cwd" --no-optional-locks rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$cwd" --no-optional-locks branch --show-current 2>/dev/null)
fi

DIM=$(tput dim 2>/dev/null); CYAN=$(tput setaf 6 2>/dev/null); GREEN=$(tput setaf 2 2>/dev/null)
YELLOW=$(tput setaf 3 2>/dev/null); MAGENTA=$(tput setaf 5 2>/dev/null); RESET=$(tput sgr0 2>/dev/null)
SEP=" ${DIM}|${RESET} "

out="${CYAN}${dir_display}${RESET}"
[ -n "$branch" ] && out+=" ${GREEN}(${branch})${RESET}"

m="${YELLOW}${model}${RESET}"
[ -n "$effort" ] && m+="${DIM} · ${effort}${RESET}"
[ "$fast" = "true" ] && m+=" ${MAGENTA}⚡fast${RESET}"
out+="${SEP}${m}"

[ -n "$remaining" ] && out+="${SEP}${DIM}Ctx: $(printf '%.0f' "$remaining")%${RESET}"

if [ -n "$h5" ]; then
  s="5h: $(printf '%.0f' "$h5")%"
  [ -n "$h5_reset" ] && s+=" ↻$(date -d "@$h5_reset" +%H:%M 2>/dev/null)"
  out+="${SEP}${DIM}${s}${RESET}"
fi
if [ -n "$d7" ]; then
  s="7d: $(printf '%.0f' "$d7")%"
  [ -n "$d7_reset" ] && s+=" ↻$(date -d "@$d7_reset" '+%a %H:%M' 2>/dev/null)"
  out+="${SEP}${DIM}${s}${RESET}"
fi

[ -n "$session" ] && out+="${SEP}${DIM}${session}${RESET}"

printf '%s' "$out"
