#!/usr/bin/env bash
#
# Just ensure that simple execution and loading doesn't fail.

(
  source "$(dirname "${BASH_SOURCE[0]}")/../modern.sh"
  say "$(scriptname)"
)

(
  "$(dirname "${BASH_SOURCE[0]}")/../modern.sh"
)
