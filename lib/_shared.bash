#!/usr/bin/env bash

set -o nounset

# datatype functions
array_contains () {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}


# WRAPPER FUNCTIONS

# if cd fails then we should exit
safe_cd() {
  say "entering directory \`$1\`"
  cd "$1" || die "safe_cd: couldn't change directory to \`$1\`";
}
# used for conditionals to determine presence of a command or executable
command_exists() { command -v "$1" > /dev/null 2>&1; }
# usage: run "title" <command> [args]
# display command to run, confirm it exists, run it, output a warning on failure
run() {
  say "running $1 command: \`${*:2}\`"
  if command_exists "$2"; then
    "${@:2}"
    ret=$?
    [[ $ret ]] || warn "$1 command exited with status code $?"
    return $ret
  else
    warn "command \`$2\` not found"
    return 255
  fi
}
# usage: run_or_die "title" <command> [args]
# as run, but die if command missing or exits with an error
run_or_die() {
  say "running $1 command: \`${*:2}\`"
  command_exists "$2" || die "command \`$2\` not found"
  $2 "${@:3}" || die_status $? "$2 command"
}

# UTILITY FUNCTIONS

# usage: realpath <path>
# attempts to resolve all symlinks until the origin path is discovered
# circular symlinks will keep it looping forever
realpath() {
  p="$1"
  # loop until the file is no longer a symlink (or doesn't exist)
  while [[ -h $p ]]; do
    d="$( cd -P "$( dirname "$p" )" && pwd )"
    p="$(readlink -e "$p")"
    # if $p was a relative symlink
    # we need to resolve it relative to the path where the symlink file was located
    [[ $p != /* ]] && p="$d/$p"
  done
  cd -P "$(dirname "$p")" && pwd
}

# usage: elapsed <start_time> <end_time>
# takes two unix timestamps with nanoseconds
# returns the difference in human-readable format
elapsed() {
  started_at=$1
  ended_at=$2

  if [[ -x $(which bc) ]]; then
    dt=$(echo "$ended_at - $started_at" | bc)
    dd=$(echo "$dt/86400" | bc)
    dt2=$(echo "$dt-86400*$dd" | bc)
    dh=$(echo "$dt2/3600" | bc)
    dt3=$(echo "$dt2-3600*$dh" | bc)
    dm=$(echo "$dt3/60" | bc)
    ds=$(echo "$dt3-60*$dm" | bc)

    printf " -- time elapsed: %d:%02d:%02d:%02.4f\n" "$dd" "$dh" "$dm" "$ds"
  else
    warn "START: $started_at"
    warn "END: $ended_at"
  fi
}

# COMPATIBILITY FUNCTIONS

# usage: gfix <command> <opts>
# example: gfix readlink -m .
# will try to prefix the command with a g
# newer versions of macOS have broken the ability to reliably modify the path in subshells
gfix() {
  if command_exists g$1; then
    g$1 "${@:2}"
  else
    "$1"
  fi
}

readlink() {
  gfix readlink "$@"
}

basename() {
  gfix basename "$@"
}

date() {
  gfix date "$@"
}

stat() {
  gfix stat "$@"
}

# STARTUP

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
