# INIT
#
# Basic initialization.
# Don't overwrite these values manually.

set -o nounset

if [[ -z ${_BASH_SHARED_LIB+unset} ]]; then
  declare -a _BASH_SHARED_LIB
  _BASH_SHARED_LIB=("$(readlink -e "${BASH_SOURCE[0]}")")
else
  return 0
fi

MODERN_SCRIPT_QUIET=""
export MODERN_SCRIPT_QUIET

MODERN_SCRIPT_ARGS=( )
export MODERN_SCRIPT_ARGS

MODERN_SCRIPT_ARGS_UNKNOWN=( )
export MODERN_SCRIPT_ARGS_UNKNOWN

while (( $# )); do
  case $1 in
    "quiet")
      MODERN_SCRIPT_QUIET=true
    ;;
    *)
      MODERN_SCRIPT_ARGS_UNKNOWN+=( "$1" )
    ;;
  esac

  MODERN_SCRIPT_ARGS+=( "$1" )
  shift
done

if [[ $MODERN_SCRIPT_QUIET != "true" ]]; then
  echo " -- ($(basename "$(dirname "$(readlink -m "${BASH_SOURCE[-1]}")")")/$(basename "${BASH_SOURCE[-1]}") @ $(date "+%Y-%m-%d %T")) : setting up..." >&2
fi
