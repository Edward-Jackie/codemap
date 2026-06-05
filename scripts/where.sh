#!/usr/bin/env bash
# where.sh — resolve the CURRENT line number(s) of a symbol's definition in a file.
#
# CODEMAP stores only "file + symbol name" — stable, never goes stale. When you want a
# line number to jump to, compute it FRESH with this script rather than trusting any
# stored number. The line number becomes a query result, not cached (decayable) data.
#
# Usage:
#   scripts/where.sh <file> <symbol>
#   e.g.  scripts/where.sh proxy/service/billing_service.go PostConsume
#
# Prints "<line>:<source>" for each definition-style match (Go/TS/JS/Python/Vue/Java-ish).
# If no definition is found, falls back to listing every occurrence of the symbol.

set -uo pipefail

FILE="${1:?usage: where.sh <file> <symbol>}"
SYM="${2:?usage: where.sh <file> <symbol>}"
[ -f "$FILE" ] || { echo "no such file: $FILE" >&2; exit 1; }

# Identifier boundary (portable across GNU/BSD grep — avoids \b).
B='[^A-Za-z0-9_]'

# Definition-style patterns:
#   func [(recv)] Name( | function/def/class/type/interface Name | const/let/var Name = | Name(...) { (method)
defs="$(grep -nE \
  "(func|function|def|class|type|interface)[[:space:]]+(\([^)]*\)[[:space:]]*)?${SYM}(${B}|$)|(const|let|var)[[:space:]]+${SYM}[[:space:]]*=|(^|${B})${SYM}[[:space:]]*\([^)]*\)[[:space:]]*\{" \
  "$FILE" 2>/dev/null || true)"

if [ -n "$defs" ]; then
  echo "$defs"
else
  echo "(no definition match for '${SYM}' — all occurrences:)"
  grep -nE "(^|${B})${SYM}(${B}|$)" "$FILE" 2>/dev/null || echo "  symbol not found in $FILE"
fi
