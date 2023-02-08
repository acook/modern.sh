# SCRIPT
#
# Crucial functions for managing scripts.

# required for the warn function to show errors
#needs display

# usage: displayname <path>
# example: displayname "$(pwd)"
# takes a path and generates "last_folder/filename" string
displayname() {
  basename -z "$(dirname "$(readlink -m "$1")")" | tr -d '\0'
  echo -ne "/"
  basename "$1"
}

# usage: scriptname
# example: echo "the current script is $(scriptname)"
# formats the current script name for display
scriptname() { displayname "$SCRIPT_CURRENT_PATH"; }

# usage: scriptcaller
# example: scriptcaller
# determine the currently executing script via caller
# !! can't be nested in other functions !!
scriptcaller() { readlink -e "$(caller | cut -d " " -f2-)"; }

# usage: scriptsame
# example: if scriptsame; then echo "this is the primary script"; fi
# for conditionals, determines if caller is the same as the main parent script
scriptsame() { [[ $SCRIPT_MAIN_PATH == "$SCRIPT_CURRENT_PATH" ]]; }

# usage: include <script>
# example: include "time.bash"
# source a script only once
include() {
  local fullpath="$SCRIPT_SHARED_DIR/_$1.bash"
  if [[ ! -f $fullpath ]]; then
    die "unable to include \`$fullpath\`: file not found"
  fi
  if [[ ! " ${_BASH_SHARED_LIB[*]} " == *" ${1} "* ]]; then
    _BASH_SHARED_LIB+=("$1")
    _set_scriptcurrent "$fullpath"
    source "$fullpath" || die "error including $fullpath"
    _set_scriptcurrent
  fi
}

# usage: load_nonfatal <script>
# example: load_nonfatal missing_script.sh
# source a script once or more, warning on errors
load_nonfatal() {
  local EXITSTATUS

  if [[ ! -f $1 ]]; then
    warn "load: file \`$1\` not found"
    return 255
  fi

  _set_scriptcurrent "$1"
  source "$1"
  EXITSTATUS=$?
  _set_scriptcurrent

  if [[ $EXITSTATUS -ne 0 ]]; then
    warn "load: \`$1\` gave exit status $EXITSTATUS"
    return $EXITSTATUS
  fi
}

# usage: load <script>
# example: load vital_script.sh
# source a script once or more, exiting if it is missing or returns an error
load() {
  local EXITSTATUS
  load_nonfatal "$1"
  EXITSTATUS=$?
  _set_scriptcurrent
  [[ $EXITSTATUS -eq 0 ]] || die_status $EXITSTATUS "error loading \`$1\`"
}

# usage: bash_trace
# example: bash_trace
# for debugging bash functions
bash_trace() {
  local frame=0
  echo -ne "TRACE ($frame): "
  while caller $frame; do
    ((frame++));
    echo -ne "TRACE ($frame): "
  done
  echo BASH
}

# usage: _set_scriptcurrent
# example: _set_scriptcurrent
# used internally to set the current script global
# if this gets broken all hell breaks loose
_set_scriptcurrent() {
  local fallback=${BASH_SOURCE[2]}
  local script=${1:-$fallback}

  SCRIPT_CURRENT_PATH=$(readlink -m "$script");
}
