#!/usr/bin/env bash
# Create a new sprint readout deck from the skill template, with the theme,
# the per-machine brand overrides and the presenter identity already applied.
#
# Usage: new_deck.sh <since:YYYY-MM-DD> <until:YYYY-MM-DD> [output-dir]
#
# Configuration is read from, in order of precedence:
#   1. environment variables already set in the shell
#   2. $SPRINT_READOUT_CONFIG, if set
#   3. <skill>/config.env
#   4. the defaults below
set -euo pipefail

SINCE="${1:-}"
UNTIL="${2:-}"
if [ -z "$SINCE" ] || [ -z "$UNTIL" ]; then
  echo "usage: new_deck.sh <since:YYYY-MM-DD> <until:YYYY-MM-DD> [output-dir]" >&2
  exit 2
fi

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# shellcheck disable=SC1090
CONFIG="${SPRINT_READOUT_CONFIG:-$SKILL_DIR/config.env}"
if [ -f "$CONFIG" ]; then
  set -a; . "$CONFIG"; set +a
fi

PRESENTER_NAME="${PRESENTER_NAME:-$(git config user.name 2>/dev/null || echo Presenter)}"
TEAM_NAME="${TEAM_NAME:-Team}"
FOOTER_LEFT="${FOOTER_LEFT:-$TEAM_NAME}"
OUTPUT_DIR="${3:-${OUTPUT_DIR:-$HOME/presentations}}"

OUT="$OUTPUT_DIR/sprint-readout-${SINCE}-to-${UNTIL}.html"
if [ -e "$OUT" ]; then
  echo "refusing to overwrite existing deck: $OUT" >&2
  exit 1
fi
mkdir -p "$OUTPUT_DIR"

# Build a :root override block from whichever BRAND_* keys are set.
brand_css=""
add_var() {
  [ -n "${2:-}" ] || return 0
  brand_css="${brand_css}  ${1}: ${2};
"
}
add_var "--accent"   "${BRAND_ACCENT:-}"
add_var "--accent-2" "${BRAND_ACCENT_2:-}"
add_var "--warm"     "${BRAND_WARM:-}"
add_var "--alert"    "${BRAND_ALERT:-}"
add_var "--gold"     "${BRAND_GOLD:-}"
add_var "--bg"       "${BRAND_BG:-}"
add_var "--panel"    "${BRAND_PANEL:-}"
add_var "--border"   "${BRAND_BORDER:-}"
if [ -n "$brand_css" ]; then
  brand_css=":root {
${brand_css}}"
fi
if [ -n "${BRAND_STRIPE:-}" ]; then
  brand_css="${brand_css}
.stripe { background: ${BRAND_STRIPE}; }"
fi

PRESENTER_NAME="$PRESENTER_NAME" TEAM_NAME="$TEAM_NAME" FOOTER_LEFT="$FOOTER_LEFT" \
BRAND_CSS="$brand_css" \
python3 - "$SKILL_DIR/assets/template.html" "$SKILL_DIR/assets/theme.css" "$OUT" <<'PY'
import html, os, pathlib, sys

tpl, css, out = (pathlib.Path(p) for p in sys.argv[1:4])


def indent(text):
    return "\n".join("    " + l if l.strip() else l for l in text.splitlines())


doc = tpl.read_text()
doc = doc.replace("/* @THEME */", indent(css.read_text()))
doc = doc.replace("/* @BRAND */", indent(os.environ.get("BRAND_CSS", "")))
for key in ("PRESENTER_NAME", "TEAM_NAME", "FOOTER_LEFT"):
    doc = doc.replace("{{%s}}" % key, html.escape(os.environ.get(key, "")))
out.write_text(doc)
PY

echo "$OUT"
