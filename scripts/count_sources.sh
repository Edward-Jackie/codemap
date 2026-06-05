#!/usr/bin/env bash
# count_sources.sh — count non-generated source files to drive the Step 2 layering decision.
#
# Usage:
#   scripts/count_sources.sh [ROOT]                          # ROOT defaults to "."
#   CODEMAP_EXCLUDE='regex' scripts/count_sources.sh [ROOT]  # add project-specific excludes
#
# Prints the non-generated source-file count, a per-extension breakdown, and a
# layering hint (<=50 -> single-layer, >50 -> two-layer). The exclude lists below
# are best-effort defaults across common stacks, not exhaustive — override per project
# with CODEMAP_EXCLUDE when a generated path slips through.

set -uo pipefail

ROOT="${1:-.}"

# Dependency / build-output / VCS dirs — never hand-written source.
EXCLUDE_DIRS='/(\.git|node_modules|vendor|dist|build|out|target|coverage|__pycache__|\.venv|venv|\.next|\.nuxt|\.idea|\.vscode|bin|obj)/'
# Generated / lock / minified files.
EXCLUDE_FILES='(\.gen\.go|\.pb\.go|_pb2\.py|\.min\.(js|css)|-lock\.(json|ya?ml)|\.lock|\.map)$|/migrations?/'
# Source extensions worth counting.
EXT='\.(go|py|js|jsx|ts|tsx|vue|java|kt|rb|rs|php|c|h|cc|cpp|hpp|cs|swift|scala|m|sh|sql)$'
# Optional project-specific extra exclude pattern.
EXTRA="${CODEMAP_EXCLUDE:-}"

files="$(find "$ROOT" -type f 2>/dev/null \
  | grep -E "$EXT" \
  | grep -Ev "$EXCLUDE_DIRS" \
  | grep -Ev "$EXCLUDE_FILES" || true)"

if [ -n "$EXTRA" ]; then
  files="$(printf '%s\n' "$files" | grep -Ev "$EXTRA" || true)"
fi

count="$(printf '%s\n' "$files" | grep -c . || true)"
[ -z "$count" ] && count=0

echo "Non-generated source files under '$ROOT': $count"
echo
echo "By extension:"
printf '%s\n' "$files" | grep -oE "$EXT" | sort | uniq -c | sort -rn
echo
if [ "$count" -le 50 ]; then
  echo "Layering hint: <=50 -> single-layer mode (one .claude/CODEMAP.md)"
else
  echo "Layering hint: >50 -> two-layer mode (top-level + per-module CODEMAP-<module>.md)"
fi
