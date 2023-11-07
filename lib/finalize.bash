# FINALIZE
#
# Finalization of setup.
# Don't overwrite these values manually.

SCRIPT_SHARED_PATH="$(readlink -e "${BASH_SOURCE[0]}")" # get the full path to this file being included
SCRIPT_SHARED_NAME="$(basename "$SCRIPT_SHARED_PATH")"  # name of this file being included (typically "modern.sh")
SCRIPT_SHARED_DIR="$(dirname "$SCRIPT_SHARED_PATH")"    # directory that contains this file being included
SCRIPT_ORIG_PWD="$(pwd -P)"                             # directory that execution began in, should we need to reference it later

SCRIPT_MAIN_PATH="$(readlink -e "$0")"                  # get the full path to the file that was originally run, which later included this file
SCRIPT_MAIN_NAME="$(basename "$SCRIPT_MAIN_PATH")"      # name of the file that was originally run
SCRIPT_MAIN_DIR="$(dirname "$SCRIPT_MAIN_PATH")"        # directory that contains the file that was originally run
SCRIPT_MAIN_EXE="$(basename "$SCRIPT_MAIN_DIR")/$SCRIPT_MAIN_NAME" # reconstruct the full path, should be identical to SCRIPT_MAIN_PATH

# initialize the SCRIPT_CURRENT_PATH variable
# will be overwritten by _set_scriptcurrent
SCRIPT_CURRENT_PATH=$SCRIPT_SHARED_PATH

export SCRIPT_SHARED_PATH
export SCRIPT_SHARED_NAME
export SCRIPT_SHARED_DIR
export SCRIPT_ORIG_PWD

export SCRIPT_MAIN_PATH
export SCRIPT_MAIN_NAME
export SCRIPT_MAIN_DIR
export SCRIPT_MAIN_EXE

export SCRIPT_CURRENT_PATH

_set_scriptcurrent
