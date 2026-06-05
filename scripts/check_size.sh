#!/usr/bin/env bash
# check_size.sh — report which CODEMAP*.md files exceed the line threshold,
# so the skill knows what to split into per-module files / offload to the changelog.
#
# Usage:
#   scripts/check_size.sh [DIR] [THRESHOLD]
#     DIR        directory holding the CODEMAP files (default: .claude)
#     THRESHOLD  line limit before a file should be split (default: 200)
#
# It only REPORTS sizes. Deciding what content moves where — detailed call chains
# into CODEMAP-<module>.md, Change Log entries into CODEMAP-changelog.md (single-layer)
# or the owning CODEMAP-<module>.md (two-layer) — is a judgment call the skill (Claude)
# makes from this report; a shell script can't understand the business content.

set -uo pipefail

DIR="${1:-.claude}"
THRESHOLD="${2:-200}"

shopt -s nullglob
files=("$DIR"/CODEMAP*.md)
if [ ${#files[@]} -eq 0 ]; then
  echo "No CODEMAP*.md found under '$DIR'."
  exit 0
fi

over=0
printf '%-44s %7s  %s\n' "FILE" "LINES" "STATUS"
printf '%-44s %7s  %s\n' "----" "-----" "------"
for f in "${files[@]}"; do
  n="$(wc -l < "$f" | tr -d ' ')"
  if [ "$n" -gt "$THRESHOLD" ]; then
    printf '%-44s %7s  OVER (> %s)\n' "$f" "$n" "$THRESHOLD"
    over=$((over + 1))
  else
    printf '%-44s %7s  ok\n' "$f" "$n"
  fi
done

echo
if [ "$over" -gt 0 ]; then
  echo "$over file(s) over the ${THRESHOLD}-line threshold. Offload, keeping <!-- manual --> blocks verbatim:"
  echo "  - detailed call chains  -> CODEMAP-<module>.md"
  echo "  - Change Log entries    -> CODEMAP-changelog.md (single-layer)"
  echo "                             or the owning CODEMAP-<module>.md (two-layer), <=20 entries each"
else
  echo "All within threshold — no split needed."
fi
