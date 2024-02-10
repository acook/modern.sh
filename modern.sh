#!/usr/bin/env bash
MODERN_SCRIPT_ORIG_PWD="$(pwd -P)"

if [[ -n $BASH_SOURCE ]]; then
  MODERN_SCRIPT_FULLPATH="$(readlink -e "${BASH_SOURCE[0]}")"

  MODERN_MAIN_FULLPATH="$(readlink -e "$0")"

  MODERN_SCRIPT_FILELESS="false"
else # the script was run via something like `curl https://example.com/script.bash | bash -s`
  MODERN_SCRIPT_FULLPATH="$MODERN_SCRIPT_ORIG_PWD/modern.sh"
  MODERN_MAIN_FULLPATH="$MODERN_SCRIPT_ORIG_PWD/modern.sh"
  MODERN_SCRIPT_FILELESS="true"
fi

set -o nounset

MODERN_SCRIPT_NAME="$(basename "$MODERN_SCRIPT_FULLPATH")"
MODERN_SCRIPT_DIR="$(dirname "$MODERN_SCRIPT_FULLPATH")"

MODERN_MAIN_NAME="$(basename "$MODERN_MAIN_FULLPATH")"
MODERN_MAIN_DIR="$(dirname "$MODERN_MAIN_FULLPATH")"
MODERN_MAIN_EXE="$(basename "$MODERN_MAIN_DIR")/$MODERN_MAIN_NAME"

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

array_contains () {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

say()  {
  if [[ $MODERN_QUIET == "true" ]]; then
    echo -ne " -- $*\n";
  else
    echo -ne " -- ($(scriptname) @ $(ts)) : $*\n";
  fi
}

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

hilite() {
    REGEX_SED=$(echo $1 | sed "s/[|()]/\\\&/g");
    sed "s/$REGEX_SED/$2&$(colorreset)/g"
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

txcp() {
    ssh "$1" "cat > '$3'" < "$2"
}

rxcp() {
  ssh "$1" "cat $2" > "$3"
}

sshpipe_new() { # manage multiple file descriptors, MODERN_SSH_PIPE_DIR becomes array
  export MODERN_SSH_PIPE_DIR
  local fdi
  local fdo
  local remote
  local in
  local out
  local pid
  fdi=13
  fdo=14
  remote="$1"
  in="$remote.$fdi.in"
  out="$remote.$fdo.out"
  pid="$remote.$fdi.pid"
  MODERN_SSH_PIPE_DIR="$(tmpdir sshpipe)"

  pushd "$MODERN_SSH_PIPE_DIR" || die "failed to pushd to temporary directory: $MODERN_SSH_PIPE_DIR"
  mkfifo "$in" "$out"
  ssh -tt "$remote" < "$in" > "$out" &
  echo "$!" > "$pid"
  eval "exec $fdi>$in"
  eval "exec $fdo<$out"
  popd || die "failed to popd from temporary directory"

  echo "$remote.$fdi"
}

sshpipe_close() {
  local fdi
  local fdo
  local remote
  local in
  local out
  local pid
  fdi=13
  fdo=14
  remote="$1"
  in="$remote.$fdi.in"
  out="$remote.$fdo.out"
  pid="$remote.$fdi.pid"

  pushd "$MODERN_SSH_PIPE_DIR" || die "failed to pushd to temporary directory: $MODERN_SSH_PIPE_DIR"
  eval "exec $fdi>&-"
  eval "exec $fdo>&-"
  kill "$(< "$pid")"
  echo "$pid"
  rm -v "$in" "$out" "$pid"
  popd || die "failed to popd from temporary directory"
}

sshpipe_tx() { # TODO: make it read from stdin
  local fd
  fd=13

  echo "$@" >&"$fd"
}

sshpipe_rx() {
  local fdo
  fdo=14

  while read -r -t 0.1 -u "$fdo" LINE; do
    echo "$LINE"
  done
}

resolvepath() {
  p="$1"
  while [[ -h $p ]]; do
    d="$( cd -P "$( dirname "$p" )" && pwd )"
    p="$(readlink -e "$p")"
    [[ $p != /* ]] && p="$d/$p"
  done
  cd -P "$(dirname "$p")" && pwd
}

thisdir() {
  dirname -- "$(scriptcaller)"
}

tmpdir() {
  mktemp -d "${1:-$(scriptname)}.XXXXXXXX" -t # without the -t it will create it in $PWD
}

displayname() {
  basename -z "$(dirname "$(readlink -m "$1")")" | tr -d '\0'
  echo -ne "/"
  basename "$1"
}

scriptname() { displayname "$MODERN_CURRENT_FULLPATH"; }

scriptcaller() { readlink -e "$(caller | cut -d " " -f2-)"; }

scriptsame() { [[ $MODERN_MAIN_FULLPATH == "$MODERN_CURRENT_FULLPATH" ]]; }

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

load() {
  local EXITSTATUS
  load_nonfatal "$1"
  EXITSTATUS=$?
  _set_current_script
  [[ $EXITSTATUS -eq 0 ]] || die_status $EXITSTATUS "error loading \`$1\`"
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

_set_current_script() {
  set +o nounset
  if [[ -n $1 ]]; then
    set -o nounset
    MODERN_CURRENT_FULLPATH="$(readlink -m "$1")"
  else
    set -o nounset
    if [[ $MODERN_SCRIPT_FILELESS == "true" ]]; then
      MODERN_CURRENT_FULLPATH="$MODERN_MAIN_FULLPATH"
    else
      MODERN_CURRENT_FULLPATH="${BASH_SOURCE[2]:-BASH_SOURCE[0]}"
    fi
  fi
}

ts()      { date "+%Y-%m-%d %T"; }

ts_file() { date --utc "+%Y-%m-%d-%H-%M-%S"; }

ts_unix() { date "+%s.%N"; }

elapsed() {
  started_at=$1
  ended_at=$2

  if command_exists bc; then
    dt=$(echo "$ended_at - $started_at" | bc)
    dd=$(echo "$dt/86400" | bc)
    dt2=$(echo "$dt-86400*$dd" | bc)
    dh=$(echo "$dt2/3600" | bc)
    dt3=$(echo "$dt2-3600*$dh" | bc)
    dm=$(echo "$dt3/60" | bc)
    ds=$(echo "$dt3-60*$dm" | bc)

    printf "time elapsed: %d:%02d:%02d:%02.4f\n" "$dd" "$dh" "$dm" "$ds"
  else
    warn "START: $started_at"
    warn "END: $ended_at"
  fi
}

nl_squeeze() { awk 'BEGIN{RS="";ORS="\n\n"}1' ;}

no_emptylines() {
  sed '/^\s*$/d'
}

sh_comments() { \grep ${1:-} '^\s*#'; }

no_comments() { sh_comments -v; }

stripscript() {
  no_comments | no_emptylines
}

safe_cd() {
  say "entering directory \`$1\`"
  cd "$1" || die "safe_cd: couldn't change directory to \`$1\`";
}

command_exists() { command -v "$1" 1>&- 2>&-; }

run() {
  local EXITSTATUS

  say "running $1 command: \`${*:2}\`"
  if command_exists "$2"; then
    "${@:2}"
    EXITSTATUS=$?
    [[ $EXITSTATUS ]] || warn "$1 command exited with status code $EXITSTATUS"
    return $EXITSTATUS
  else
    warn "command \`$2\` not found"
    return 255
  fi
}

run_or_die() {
  local EXITSTATUS

  run "$@"
  EXITSTATUS=$?
  [[ $EXITSTATUS ]] || die_status $EXITSTATUS "$2 command"
}

gfix() {
  if command_exists "g$1"; then
    "g$1" "${@:2}"
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

