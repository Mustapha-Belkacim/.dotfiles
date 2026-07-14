#!/usr/bin/env bash
# Generate copilot-instructions.md from the template + per-machine values.
#
# Usage:
#   ./generate-instructions.sh                # uses jira.env
#   ./generate-instructions.sh my.env         # uses a custom values file
#
# Placeholders in the template look like {{KEY}} and are replaced by the
# matching KEY=value line in the values file.

set -euo pipefail

cd "$(dirname "$0")"

TEMPLATE="copilot-instructions.template.md"
VALUES="${1:-jira.env}"
OUTPUT="copilot-instructions.md"

[[ -f "$TEMPLATE" ]] || { echo "error: template not found: $TEMPLATE" >&2; exit 1; }
[[ -f "$VALUES"   ]] || { echo "error: values file not found: $VALUES" >&2; exit 1; }

tmp="$(mktemp)"
cp "$TEMPLATE" "$tmp"

# Read KEY=value pairs (skip blanks and #comments) and substitute {{KEY}}.
while IFS= read -r line || [[ -n "$line" ]]; do
  [[ -z "$line" || "$line" == \#* ]] && continue
  key="${line%%=*}"
  val="${line#*=}"
  # trim surrounding whitespace on the key
  key="$(printf '%s' "$key" | tr -d '[:space:]')"
  [[ -z "$key" ]] && continue
  # escape sed replacement metacharacters: \, &, and the / delimiter
  esc_val="$(printf '%s' "$val" | sed -e 's/[\/&]/\\&/g')"
  sed -i.bak "s/{{${key}}}/${esc_val}/g" "$tmp"
  rm -f "$tmp.bak"
done < "$VALUES"

# Warn about any placeholders left unresolved.
if grep -o '{{[A-Za-z0-9_]*}}' "$tmp" | sort -u | grep . ; then
  echo "warning: the above placeholders were not defined in $VALUES" >&2
fi

mv "$tmp" "$OUTPUT"
echo "wrote $OUTPUT from $TEMPLATE using $VALUES"
