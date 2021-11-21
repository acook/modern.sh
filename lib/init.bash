# INIT
#
# Basic initialization.
# Don't overwrite these values manually.

set -o nounset

if [[ -z ${_BASH_SHARED_LIB+unset} ]]; then
  declare -a _BASH_SHARED_LIB
  _BASH_SHARED_LIB=("$(readlink -e "$BASH_SOURCE")")
else
  return 0
fi

echo " -- ($(basename "$(dirname "$(readlink -m "${BASH_SOURCE[-1]}")")")/$(basename "${BASH_SOURCE[-1]}") @ $(date "+%Y-%m-%d %T")) : setting up..." >&2

export SCRIPT_SHARED_PATH="$(readlink -e "$BASH_SOURCE")"
export SCRIPT_SHARED_NAME="$(basename "$SCRIPT_SHARED_PATH")"
export SCRIPT_SHARED_DIR="$(dirname "$SCRIPT_SHARED_PATH")"
export SCRIPT_ORIG_PWD="$(pwd -P)"

export SCRIPT_MAIN_PATH="$(readlink -e "$0")"
export SCRIPT_MAIN_NAME="$(basename "$SCRIPT_MAIN_PATH")"
export SCRIPT_MAIN_DIR="$(dirname "$SCRIPT_MAIN_PATH")"
export SCRIPT_MAIN_EXE="$(basename "$SCRIPT_MAIN_DIR")/$SCRIPT_MAIN_NAME"

export SCRIPT_CURRENT_PATH=$SCRIPT_SHARED_PATH

_set_scriptcurrent
