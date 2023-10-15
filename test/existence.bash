#!/usr/bin/env bash
#
# Just ensure that simple execution and loading doesn't fail.

echo "Source test..."

(
  source "$(dirname "${BASH_SOURCE[0]}")/../modern.sh"
  say "$(scriptname)"
)

echo "Standalone test..."

(
  "$(dirname "${BASH_SOURCE[0]}")/../modern.sh"
)

echo "Quiet source test..."

(
  source "$(dirname "${BASH_SOURCE[0]}")/../modern.sh" quiet
  say "$MODERN_SCRIPT_QUIET"
  say "${MODERN_SCRIPT_ARGS[@]}"
  say "$MODERN_SCRIPT_ARGS"
)

echo "(end of quiet test)"
