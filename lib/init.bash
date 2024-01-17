# INIT
#
# Basic initialization.
# Don't overwrite these values manually.

set -o nounset

if [[ -z ${_MODERN_LOADED_LIBS+unset} ]]; then
  declare -a _MODERN_LOADED_LIBS
  _MODERN_LOADED_LIBS=("$(readlink -e "${BASH_SOURCE[0]}")")
else
  return 0
fi

MODERN_QUIET="${MODERN_QUIET:-}"
export MODERN_QUIET

MODERN_ARGS=( )
export MODERN_ARGS

MODERN_ARGS_UNKNOWN=( )
export MODERN_ARGS_UNKNOWN

# if MODERN_PROCESS_ARGS is set to "true" then
# we will consume all arguments here and put them in MODERN_ARGS
# and store any we don't recogize in MODERN_ARGS_UNKNOWN
if [[ MODERN_PROCESS_ARGS == "true" ]]; then
  while (( $# )); do
    case $1 in
      "quiet")
        MODERN_QUIET=true
      ;;
      *)
        MODERN_ARGS_UNKNOWN+=( "$1" )
      ;;
    esac

    MODERN_ARGS+=( "$1" )
    shift
  done
fi

if [[ $MODERN_QUIET != "true" ]]; then
  echo " -- ($(basename "$(dirname "$(readlink -m "${BASH_SOURCE[-1]}")")")/$(basename "${BASH_SOURCE[-1]}") @ $(date "+%Y-%m-%d %T")) : setting up..." >&2
fi
