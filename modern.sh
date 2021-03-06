#!/usr/bin/env bash

say()  { echo -ne " -- ($(scriptname) @ $(ts)) : $*\n"; }

warn() { say "$*" >&2; }

sayenv() { say "$1=$(eval "echo -ne \$$1")"; }

colorfg() {
  case "$1" in
  ("black") color=30 ;;
  ("red") color=31 ;;
  ("green") color=32 ;;
  ("yellow") color=33 ;;
  ("blue") color=34 ;;
  ("magenta") color=35 ;;
  ("cyan") color=36 ;;
  ("white") color=37 ;;

  ("green3") color="38;5;34" ;;
  ("red3") color="38;5;160" ;;
  ("orangered") color="38;5;202" ;;
  ("violet") color="38;5;128" ;;
  (*) color="38;5;$1" ;;
  esac
  echo -ne "\e[$color""m"
}

colorbg() {
  case "$1" in
  ("black") color=40 ;;
  ("red") color=41 ;;
  ("green") color=42 ;;
  ("yellow") color=43 ;;
  ("blue") color=44 ;;
  ("magenta") color=45 ;;
  ("cyan") color=46 ;;
  ("white") color=47 ;;

  ("green3") color="48;5;34" ;;
  ("red3") color="48;5;160" ;;
  ("orangered") color="48;5;202" ;;
  ("violet") color="48;5;128" ;;
  (*) color="48;5;$1" ;;
  esac
  echo -ne "\e[$color""m"
}

colorreset() {
  echo -ne "\e[0m"
}

ansigoto() {
  echo -ne "\e[$1""G"
}

ansieol() {
  echo -ne "\e[K"
}

ansiup() {
  echo -ne "\e[$1""A"
}




displayname() {
  basename -z "$(dirname "$(readlink -m "$1")")" | tr -d '\0'
  echo -ne "/"
  basename "$1"
}

scriptname() { displayname "$SCRIPT_CURRENT_PATH"; }

scriptcaller() { readlink -e "$(caller | cut -d " " -f2-)"; }

scriptsame() { [[ $SCRIPT_MAIN_PATH == "$SCRIPT_CURRENT_PATH" ]]; }

include() {
  local fullpath="$SCRIPT_SHARED_DIR/_$1.bash"
  if [[ ! -f $fullpath ]]; then
    die "unable to include \`$fullpath\`: file not found"
  fi
  if [[ ! " ${_BASH_SHARED_LIB[@]} " == *" ${1} "* ]]; then
    _BASH_SHARED_LIB+=("$1")
    _set_scriptcurrent "$fullpath"
    source "$fullpath" || die "error including $fullpath"
    _set_scriptcurrent
  fi
}

load_nonfatal() {
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

load() {
  load_nonfatal "$1"
  EXITSTATUS=$?
  _set_scriptcurrent
  [[ $EXITSTATUS -eq 0 ]] || die_status $? "error loading \`$1\`"
}

bash_trace() {
  local frame=0
  echo -ne "TRACE ($frame): "
  while caller $frame; do
    ((frame++));
    echo -ne "TRACE ($frame): "
  done
  echo BASH
}

_set_scriptcurrent() {
  local fallback=${BASH_SOURCE[2]}
  local script=${1:-$fallback}

  SCRIPT_CURRENT_PATH=$(readlink -m "$script");
}



ok()   { say "\e[32m(ok) $*\e[0m"; exit 0; }

die()  { warn "\e[31m(die) $*\e[0m"; exit 1; }

die_status() { warn "\e[31m(died with status code $1) ${*:2}\e[0m"; exit "$1"; }

quit_status() {
  if scriptsame; then
    if [[ $1 -eq 0 ]]; then
      ok "${*:2}"
    else
      die_status "$@"
    fi
  else
    if [[ $1 -eq 0 ]]; then
      say "${*:2}"
    else
      warn "${*:2}"
    fi
    return "$1"
  fi
}


ts()      { date "+%Y-%m-%d %T"; }

ts_file() { date --utc "+%Y-%m-%d-%H-%M-%S"; }

ts_unix() { date "+%s.%N"; }


realpath() {
  p="$1"
  while [[ -h $p ]]; do
    d="$( cd -P "$( dirname "$p" )" && pwd )"
    p="$(readlink -e "$p")"
    [[ $p != /* ]] && p="$d/$p"
  done
  cd -P "$(dirname "$p")" && pwd
}

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



safe_cd() {
  say "entering directory \`$1\`"
  cd "$1" || die "safe_cd: couldn't change directory to \`$1\`";
}

command_exists() { command -v "$1" > /dev/null 2>&1; }

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

run_or_die() {
  say "running $1 command: \`${*:2}\`"
  command_exists "$2" || die "command \`$2\` not found"
  $2 "${@:3}" || die_status $? "$2 command"
}


gfix() {
  if command_exists g$1; then
    g$1 "${@:2}"
  else
    "$1"
  fi
}

if [[ Darwin = $(uname) ]]; then

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

fi


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
