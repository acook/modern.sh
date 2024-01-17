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
scriptname() { displayname "$MODERN_CURRENT_FULLPATH"; }

# usage: scriptcaller
# example: scriptcaller
# determine the currently executing script via caller
# !! can't be nested in other functions !!
scriptcaller() { readlink -e "$(caller | cut -d " " -f2-)"; }

# usage: scriptsame
# example: if scriptsame; then echo "this is the primary script"; fi
# for conditionals, determines if caller is the same as the main parent script
scriptsame() { [[ $MODERN_MAIN_FULLPATH == "$MODERN_CURRENT_FULLPATH" ]]; }

# usage: include <script>
# example: include "time.bash"
# source a script only once
include() {
  local fullpath="$MODERN_SCRIPT_DIR/_$1.bash"
  if [[ ! -f $fullpath ]]; then
    die "unable to include \`$fullpath\`: file not found"
  fi
  if [[ ! " ${_MODERN_LOADED_LIBS[*]} " == *" ${1} "* ]]; then
    _MODERN_LOADED_LIBS+=("$1")
    _set_current_script "$fullpath"
    source "$fullpath" || die "error including $fullpath"
    _set_current_script
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

  _set_current_script "$1"
  source "$1"
  EXITSTATUS=$?
  _set_current_script

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
  _set_current_script
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

# usage: _set_current_script
# example: _set_current_script
# used internally to set the current script global used by `scriptsame` and `scriptname`
# if this gets broken then:
# - `scriptname`: it may become difficult to trace errors as reported messages will incorrectly identify the script they originated from
# - `scriptsame`: files which can be used as both a library and an executable will no longer be able to determine what they should be doing
_set_current_script() {
  local fallback=${BASH_SOURCE[2]:-BASH_SOURCE[0]}
  local script=${1:-$fallback}

  MODERN_CURRENT_FULLPATH=$(readlink -m "$script");
}
