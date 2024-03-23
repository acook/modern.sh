 ## FINALIZE
 #
 # Finalization of setup.
 # Don't overwrite these values manually.

_set_current_script

set +o nounset
if [[ -z $TMPDIR ]]; then
  TMPDIR="/tmp"
fi
set -o nounset

if ! [[ -w $TMPDIR ]]; then
  warn "TMPDIR '$TMPDIR' not writable! using '.' instead"
  TMPDIR='.'
fi

if [[ $MODERN_DOWNLOAD_SELF == "true" ]]; then
  modern_sh_install
fi

if [[ $MODERN_UPDATE_SELF == "true" ]]; then
  modern_sh_update
fi

if [[ $MODERN_START_SHELL == "true" ]]; then
  start_interactive_modern_shell
fi
