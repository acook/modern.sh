# FINALIZE
#
# Finalization of setup.
# Don't overwrite these values manually.

# directory that execution began in
# useful if we lose track of where we started after `cd`
MODERN_SCRIPT_ORIG_PWD="$(pwd -P)"

# get the full path to this file being included (typically ending in "modern.sh")
MODERN_SCRIPT_FULLPATH="$(readlink -e "${BASH_SOURCE[0]}")"
# name of this file being included (typically "modern.sh")
MODERN_SCRIPT_NAME="$(basename "$MODERN_SCRIPT_FULLPATH")"
# directory that contains this file being included
# particularly useful if we want to store other libraries relative to it
MODERN_SCRIPT_DIR="$(dirname "$MODERN_SCRIPT_FULLPATH")"

# get the full path to the script that was originally run
# this is typically the one that later included modern.sh
MODERN_MAIN_FULLPATH="$(readlink -e "$0")"
# name of the file that was originally run
MODERN_MAIN_NAME="$(basename "$MODERN_MAIN_FULLPATH")"
# directory that contains the file that was originally run
MODERN_MAIN_DIR="$(dirname "$MODERN_MAIN_FULLPATH")"
# reconstruct the full path, should be identical to SCRIPT_MAIN_PATH, but not always
MODERN_MAIN_EXE="$(basename "$MODERN_MAIN_DIR")/$MODERN_MAIN_NAME"

# initialize the MODERN_CURRENT_FULLPATH variable before it is exported
# will be overwritten by _set_current_script shortly
MODERN_CURRENT_FULLPATH=$MODERN_SCRIPT_FULLPATH

export MODERN_SCRIPT_FULLPATH
export MODERN_SCRIPT_NAME
export MODERN_SCRIPT_DIR
export MODERN_SCRIPT_DIR

export MODERN_MAIN_FULLPATH
export MODERN_MAIN_NAME
export MODERN_MAIN_DIR
export MODERN_MAIN_EXE

export MODERN_CURRENT_FULLPATH

_set_current_script
