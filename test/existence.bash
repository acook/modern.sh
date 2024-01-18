#!/usr/bin/env bash
#
# Just ensure that simple execution and loading doesn't fail.

echo "Source test..."

(
  source "$(dirname "${BASH_SOURCE[0]}")/../modern.sh"
  say "$(scriptname)"
  echo -e "1. foo bar baz\n2. nothing highlighted\n3. bar bar jar" | hilite bar $(colorfg green)
)

echo "Standalone test..."

(
  "$(dirname "${BASH_SOURCE[0]}")/../modern.sh"
)

echo "Quiet source test..."

(
  MODERN_PROCESS_ARGS=true
  export MODERN_PROCESS_ARGS
  source "$(dirname "${BASH_SOURCE[0]}")/../modern.sh" quiet unknown
  say "$MODERN_QUIET"
  say "${MODERN_ARGS[@]}"
  say "$MODERN_ARGS"
  say "$MODERN_ARGS_UNKNOWN"
)

echo "(end of quiet test)"
