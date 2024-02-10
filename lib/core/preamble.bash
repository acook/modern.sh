# INIT
#
# Basic initialization.
# Don't overwrite these values manually.

# directory that execution began in
# useful if we lose track of where we started after `cd`
MODERN_SCRIPT_ORIG_PWD="$(pwd -P)"

# shellcheck disable=SC2128
if [[ -n $BASH_SOURCE ]]; then
  # get the full path to this file being included (typically ending in "modern.sh")
  MODERN_SCRIPT_FULLPATH="$(readlink -e "${BASH_SOURCE[0]}")"

  # get the full path to the script that was originally run
  # this is typically the one that later included modern.sh
  MODERN_MAIN_FULLPATH="$(readlink -e "$0")"

  # lets modern.sh functions know that there is no file to load from
  MODERN_SCRIPT_FILELESS="false"
else # the script was run via something like `curl https://example.com/script.bash | bash -s`
  MODERN_SCRIPT_FULLPATH="$MODERN_SCRIPT_ORIG_PWD/modern.sh"
  MODERN_MAIN_FULLPATH="$MODERN_SCRIPT_ORIG_PWD/modern.sh"
  MODERN_SCRIPT_FILELESS="true"
fi

set -o nounset

# name of this file being included (typically "modern.sh")
MODERN_SCRIPT_NAME="$(basename "$MODERN_SCRIPT_FULLPATH")"
# directory that contains this file being included
# particularly useful if we want to store other libraries relative to it
MODERN_SCRIPT_DIR="$(dirname "$MODERN_SCRIPT_FULLPATH")"

# name of the file that was originally run
MODERN_MAIN_NAME="$(basename "$MODERN_MAIN_FULLPATH")"
# directory that contains the file that was originally run
MODERN_MAIN_DIR="$(dirname "$MODERN_MAIN_FULLPATH")"
# reconstruct the full path, should be identical to SCRIPT_MAIN_PATH, but not always
MODERN_MAIN_EXE="$(basename "$MODERN_MAIN_DIR")/$MODERN_MAIN_NAME"

# initialize the MODERN_CURRENT_FULLPATH variable before it is exported
# will be overwritten by _set_current_script during finalize
MODERN_CURRENT_FULLPATH=$MODERN_SCRIPT_FULLPATH

if [[ -z ${_MODERN_LOADED_LIBS+unset} ]]; then
  declare -a _MODERN_LOADED_LIBS
  _MODERN_LOADED_LIBS=("$MODERN_MAIN_FULLPATH)")
else
  return 0
fi

MODERN_QUIET="${MODERN_QUIET:-false}"
export MODERN_QUIET

MODERN_ARGS=( )
export MODERN_ARGS

MODERN_ARGS_UNKNOWN=( )
export MODERN_ARGS_UNKNOWN

MODERN_PROCESS_ARGS="${MODERN_PROCESS_ARGS:-false}"

# if MODERN_PROCESS_ARGS is set to "true" then
# we will consume all arguments here and put them in MODERN_ARGS
# and store any we don't recogize in MODERN_ARGS_UNKNOWN
if [[ $MODERN_PROCESS_ARGS == "true" ]]; then
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
else
  MODERN_QUIET="false"
  MODERN_ARGS=()
  MODERN_ARGS_UNKNOWN=("$@")
fi

if [[ $MODERN_QUIET != "true" ]]; then
  echo -ne " -- ("
  basename -z "$(dirname "$MODERN_MAIN_DIR")" | tr -d '\0'
  echo -ne "/$MODERN_MAIN_NAME"
  echo -ne ") @ $(date "+%Y-%m-%d %T")) : setting up..."
  echo
fi

export MODERN_SCRIPT_ORIG_PWD

export MODERN_SCRIPT_FULLPATH
export MODERN_SCRIPT_NAME
export MODERN_SCRIPT_DIR
export MODERN_SCRIPT_DIR

export MODERN_MAIN_FULLPATH
export MODERN_MAIN_NAME
export MODERN_MAIN_DIR
export MODERN_MAIN_EXE

export MODERN_SCRIPT_FILELESS

export MODERN_CURRENT_FULLPATH
