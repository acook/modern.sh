#!/usr/bin/env bash
 ## INIT
 #
 # Basic initialization.
 # Don't overwrite these values manually.

 # directory that execution began in
 # useful if we lose track of where we started after `cd`
MODERN_SCRIPT_ORIG_PWD="$(pwd -P)"

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

if [[ -z ${MODERN_PROCESS_ARGS+unset} ]]; then
  if [[ $MODERN_MAIN_FULLPATH == "$MODERN_SCRIPT_FULLPATH" ]]; then
    MODERN_PROCESS_ARGS="true"
  else
    MODERN_PROCESS_ARGS="false"
  fi
fi

if [[ $MODERN_PROCESS_ARGS == "true" ]]; then
  while (( $# )); do
    case $1 in
      "quiet")
        MODERN_QUIET=true
      ;;
      "shell")
        MODERN_START_SHELL=true
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

MODERN_START_SHELL="${MODERN_START_SHELL:-false}"

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
export -f say

warn() { say "$*" >&2; }
export -f warn

sayenv() { say "$1=$(eval "echo -ne \$$1")"; }
export -f sayenv

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
export -f colorfg

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
export -f colorbg

colorreset() {
  echo -ne "\e[0m"
}
export -f colorreset

ansigoto() {
  echo -ne "\e[$1""G"
}
export -f ansigoto

ansieol() {
  echo -ne "\e[K"
}
export -f ansieol

ansiup() {
  echo -ne "\e[$1""A"
}
export -f ansiup

hilite() {
    sed "s/$1/$2&$(colorreset)/g"
}
export -f hilite

ok()   { say "\e[32m(ok) $*\e[0m"; exit 0; }
export -f ok

die()  { warn "\e[31m(die) $*\e[0m"; exit 1; }
export -f die

die_status() { warn "\e[31m(died with status code $1) ${*:2}\e[0m"; exit "$1"; }
export -f die_status

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
export -f quit_status

txcp() {
    # shellcheck disable=SC2029
    ssh "$1" "cat > '$3'" < "$2"
}
export -f txcp

rxcp() {
  # shellcheck disable=SC2029
  ssh "$1" "cat $2" > "$3"
}
export -f rxcp

sshpipe_new() { # manage multiple file descriptors, MODERN_SSH_PIPE_DIR becomes array
  export MODERN_SSH_PIPE_DIR
  local fdi
  local fdo
  local remote
  local command
  local quiet
  local print
  local in
  local out
  local pid
  local status
  local connected
  local delay
  local checks
  local max_checks
  fdi=13
  fdo=14

  quiet="false"
  print="false"

  while (( $# )); do
    case $1 in
      "-q")
        quiet="true"
      ;;
      "-p")
        print="true"
      ;;
      *)
        remote="$1"
        shift
        break
      ;;
    esac

    shift
  done

  if [[ -n ${1:-unset} ]]; then
    command=("$@")
  else
    command=()
  fi

  in="$remote.$fdi.in"
  out="$remote.$fdo.out"
  pid="$remote.$fdi.pid"
  status="$remote.$fdi.status"
  MODERN_SSH_PIPE_DIR="$(tmpdir sshpipe)"

  pushd "$MODERN_SSH_PIPE_DIR" 1>&- 2>&- || die "sshpipe: failed to pushd to temporary directory: $MODERN_SSH_PIPE_DIR"
  mkfifo "$in" "$out"
  ( ssh -o BatchMode=yes -tt "$remote" "${command[@]}" < "$in" > "$out" ; echo -n "$?" > "$status" ) &
  SSHPIPEPID="$!"
  echo "$SSHPIPEPID" > "$pid"
  eval "exec $fdi>$in"
  eval "exec $fdo<$out"
  popd 1>&- 2>&- || die "sshpipe: failed to popd from temporary directory"

  delay="0.5s"
  checks=0
  max_checks=25
  connected=false

  while [[ $connected = "false" && checks -lt $max_checks ]] && pid_check "$SSHPIPEPID"; do
    if [[ $quiet != "true" ]]; then
      say "sshpipe: waiting for ssh connection..."
    fi
    sleep "$delay"
    if sshpipe_status -q "$remote"; then
      connected=true
    fi
  done

  if ! pid_check "$SSHPIPEPID"; then
    wait "$SSHPIPEPID"
    exitstatus=$?
    if [[ $quiet != "true" ]]; then
      warn "sshpipe: process exited with status code $exitstatus"
    fi
    return 3
  fi

  if [[ $connected ==  "true" ]]; then
    say "sshpipe: connected to $remote!"
  else
    if [[ $quiet != "true" ]]; then
      warn "sshpipe: unable to determine if the connection is working"
    fi
  fi

  if [[ $print == "true" ]]; then
    echo "$MODERN_SSH_PIPE_DIR $fdi"
  fi
}
export -f sshpipe_new

sshpipe_status() {
  local fdi
  local fdo
  local pid
  local procid
  local remote
  local quiet
  local print
  local result
  fdi=13
  fdo=14

  quiet="false"
  print="false"

  while (( $# )); do
    case $1 in
      "-q")
        quiet="true"
      ;;
      "-p")
        print="true"
      ;;
      *)
        remote="$1"
      ;;
    esac

    shift
  done

  pid="$remote.$fdi.pid"

  if [[ ! -d $MODERN_SSH_PIPE_DIR ]]; then
    if [[ $quiet != "true" ]]; then
      warn "sshpipe: no MODERN_SSH_PIPE_DIR - try connecting with sshpipe_new <host> first?"
    fi
    return 1
  else
    procid="$(<"$MODERN_SSH_PIPE_DIR/$pid")"
  fi

  if ! fd_check "$fdi" || ! fd_check "$fdo"; then
    if [[ $quiet != "true" ]]; then
      warn "sshpipe: unable to detect the file descriptors used by sshpipe - check ssh credentials?"
    fi
    return 2
  fi

  if ! exitstatus="$(pid_check "$procid" -p)"; then
    if [[ $quiet != "true" ]]; then
      warn "sshpipe: process exited with status code $exitstatus"
    fi
    return 3
  fi

  if [[ $print == "true" ]]; then
    # redirect to stderr so it is easy to separate from the actual info
    sshpipe_rx "$remote" >&2
  else
    sshpipe_rx "$remote" > /dev/null
  fi

  # shellcheck disable=SC2028,SC2016
  echo 'printf "\133 $SHELL \174 $USER \174 $PWD \135\n"' >&"$fdi"

  result="$(sshpipe_rx "$remote")"

  regex='\[\s(.*sh)\s\|\s(.*)\s\|\s(.*)\s\]'
  if [[ $result =~ $regex ]]; then
    if [[ $print == "true" ]]; then
      echo -e "${BASH_REMATCH[1]}\t${BASH_REMATCH[2]}\t${BASH_REMATCH[3]}"
    fi
    return 0
  else
    if [[ $quiet != "true" ]]; then
      warn "sshpipe: unable to get info - disconnected or not a shell on remote?"
    fi
    return 4
  fi
}
export -f sshpipe_status

sshpipe_hostinfo() {
  local remote
  remote="$1"

  if INFO="$(sshpipe_status "$remote" -p)"; then
    echo -e "\e[31m"
    echo -n "SHELL: "
    echo "$INFO" | cut -s -f 1
    echo -n "USER:  "
    echo "$INFO" | cut -s -f 2
    echo -n "PWD:   "
    echo "$INFO" | cut -s -f 3
    echo -e "\e[0m"
  fi
}
export -f sshpipe_hostinfo

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

  pushd "$MODERN_SSH_PIPE_DIR" || die "sshpipe: failed to pushd to temporary directory: $MODERN_SSH_PIPE_DIR"
  eval "exec $fdi>&-"
  eval "exec $fdo>&-"
  kill "$(< "$pid")"
  echo "$pid"
  rm -v "$in" "$out" "$pid"
  popd || die "sshpipe: failed to popd from temporary directory"
}
export -f sshpipe_close

sshpipe_tx() { # TODO: make it read from stdin
  local fdi
  fdi=13
  shift

  echo -e "$@" >&"$fdi"
}
export -f sshpipe_tx

sshpipe_rx() {
  local fdo
  fdo=14
  shift

  while read -r -t 0.1 -u "$fdo" LINE; do
    echo "$LINE"
  done
}
export -f sshpipe_rx

resolvepath() {
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
export -f resolvepath

thisdir() {
  dirname -- "$(scriptcaller)"
}
export -f thisdir

tmpdir() {
  mktemp -d "${1:-$(scriptname)}.XXXXXXXX" -t # without the -t it will create it in $PWD
}
export -f tmpdir

fd_check() {
  local fd
  fd="$1"
  { true >&"$fd"; } 2>&-
}
export -f fd_check

pid_check() {
  local pid
  local print
  local exitstatus

  if [[ $1 == "-p" ]]; then
    print="true"
    pid="$2"
  elif [[ ${2:-unset} == "-p" ]]; then
    print="true"
    pid="$1"
  else
    print="false"
    pid="$1"
  fi

  if [[ ! -d /proc/$pid ]]; then
    # only use `wait`` if it has already exited
    # `wait` will fetch the exit code of an arbitrary pid even after it is already closed
    wait "$pid"
    exitstatus="$?"
    if [[ $print == "true" ]]; then
      echo "$exitstatus"
    fi
    return 255
  fi
  return 0
}
export -f pid_check

displayname() {
  basename -z "$(dirname "$(readlink -m "$1")")" | tr -d '\0'
  echo -ne "/"
  basename "$1"
}
export -f displayname

scriptname() { displayname "$MODERN_CURRENT_FULLPATH"; }
export -f scriptname

scriptcaller() { readlink -e "$(caller | cut -d " " -f2-)"; }
export -f scriptcaller

scriptsame() { [[ $MODERN_MAIN_FULLPATH == "$MODERN_CURRENT_FULLPATH" ]]; }
export -f scriptsame

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
export -f include

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
export -f load_nonfatal

load() {
  local EXITSTATUS
  load_nonfatal "$1"
  EXITSTATUS=$?
  _set_current_script
  [[ $EXITSTATUS -eq 0 ]] || die_status $EXITSTATUS "error loading \`$1\`"
}
export -f load

bash_trace() {
  local frame=0
  echo -ne "TRACE ($frame): "
  while caller $frame; do
    ((frame++));
    echo -ne "TRACE ($frame): "
  done
  echo BASH
}
export -f bash_trace

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
export -f _set_current_script

ts()      { date "+%Y-%m-%d %T"; }
export -f ts

ts_file() { date --utc "+%Y-%m-%d-%H-%M-%S"; }
export -f ts_file

ts_unix() { date "+%s.%N"; }
export -f ts_unix

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
export -f elapsed

nl_squeeze() { awk 'BEGIN{RS="";ORS="\n\n"}1' ;}
export -f nl_squeeze

no_emptylines() {
  sed '/^\s*$/d'
}
export -f no_emptylines

sh_comments() { \grep ${1:-} '^#'; }
export -f sh_comments

no_comments() { sh_comments -v; }
export -f no_comments

stripscript() {
  no_comments | no_emptylines
}
export -f stripscript

strand() {
  local len
  local charset
  len="${1:-8}"
  charset="${2:-A-Z0-9}"
  LC_ALL=C tr -dc "$charset" < /dev/urandom | head -c "$len"
}
export -f strand

update_modern_sh() {
  safe_cd "$MODERN_SCRIPT_DIR"
  run "downloading latest modern.sh" curl -O -L https://raw.githubusercontent.com/acook/modern.sh/main/modern.sh
}
export -f update_modern_sh

start_interactive_modern_shell() {
  /usr/bin/env bash -i <<< "source $MODERN_SCRIPT_FULLPATH; exec </dev/tty"
}
export -f start_interactive_modern_shell

safe_cd() {
  say "entering directory \`$1\`"
  cd "$1" || die "safe_cd: couldn't change directory to \`$1\`";
}
export -f safe_cd

command_exists() { command -v "$1" 1>&- 2>&-; }
export -f command_exists

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
export -f run

run_or_die() {
  local EXITSTATUS

  run "$@"
  EXITSTATUS=$?
  [[ $EXITSTATUS ]] || die_status $EXITSTATUS "$2 command"
}
export -f run_or_die

gfix() {
  if command_exists "g$1"; then
    "g$1" "${@:2}"
  else
    "$1"
  fi
}
export -f gfix

if [[ Darwin = $(uname) ]]; then

  readlink() {
    gfix readlink "$@"
  }
  export -f readlink

  basename() {
    gfix basename "$@"
  }
  export -f basename

  date() {
    gfix date "$@"
  }
  export -f date

  stat() {
    gfix stat "$@"
  }
  export -f stat

fi

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

if [[ $MODERN_START_SHELL == "true" ]]; then
  start_interactive_modern_shell
fi

