SCRIPT_QUIET=""
export SCRIPT_QUIET

case ${!:-_} in
  "quiet")
    SCRIPT_QUIET=true
  ;;
esac




# shellcheck disable=SC2005,SC2116#
#
# Ignore shellcheck errors for "pointless echo" because
#   we are using it to isolate execution into subshells
#   which prevents polluting the local environment.
echo ""
