# NETWORK
#
# This contains functions that are useful for network operations.

# usage: txcp <host> <local_filename> <remote_filename>
# example: txcp me@example.com asciiart.txt motd.txt
# send a local file to a remote host using only SSH
txcp() {
    # shellcheck disable=SC2029
    ssh "$1" "cat > '$3'" < "$2"
}

# usage: rxcp <host> <remote_filename> <local_filename>
# example: txcp me@example.com garbage.bak davinci.dat
# send a local file to a remote host using only SSH
rxcp() {
  # shellcheck disable=SC2029
  ssh "$1" "cat $2" > "$3"
}

# usage: sshpipe_new <host> <command>
# example: my_pipe="$(sshpipe_new my_host | tail -n 1)"
# create a named pipe to send bash commands to remote host
# <command> is the starting command to run instead of the default shell
sshpipe_new() { # manage multiple file descriptors, MODERN_SSH_PIPE_DIR becomes array
  export MODERN_SSH_PIPE_DIR
  local fdi
  local fdo
  local remote
  local command
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
  remote="$1"
  shift
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

  pushd "$MODERN_SSH_PIPE_DIR" || die "sshpipe: failed to pushd to temporary directory: $MODERN_SSH_PIPE_DIR"
  mkfifo "$in" "$out"
  ( ssh -o BatchMode=yes -tt "$remote" "${command[@]}" < "$in" > "$out" ; echo -n "$?" > "$status" ) &
  SSHPIPEPID="$!"
  echo "$SSHPIPEPID" > "$pid"
  eval "exec $fdi>$in"
  eval "exec $fdo<$out"
  popd || die "sshpipe: failed to popd from temporary directory"

  delay="0.25s"
  checks=0
  max_checks=25 # 5 seconds with a delay of 0.25s
  connected=false

  while [[ $connected = "false" && checks -lt $max_checks ]] && pid_check "$SSHPIPEPID"; do
    say "waiting for ssh connection..."
    sleep "$delay"
    if sshpipe_status -q "$remote"; then
      connected=true
    fi
  done

  if ! pid_check "$SSHPIPEPID"; then
    wait "$SSHPIPEPID"
    warn "sshpipe: process exited with status code $?"
    return 3
  fi

  if [[ $connected ==  "true" ]]; then
    say "sshpipe: connected to $remote!"
  else
    warn "sshpipe: unable to determine if the connection is working"
  fi

  echo "$MODERN_SSH_PIPE_DIR $fdi"
}

# usage: sshpipe_status <host> [-p]
# example: remote_shell="$(sshpipe_status my_host | cut -d '|' -f 1)"
# it returns non-zero for any errors for the detected sshpipe and reports them on stderr
# if -p is passed in, it will print the remote shell, user, and pwd in the format:
# shell|user|pwd
# if -q is passed in, it will not display warning messages and only return exit status codes
sshpipe_status() {
  local fdi
  local fdo
  local pid
  local procid
  local print
  local remote
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

    MODERN_ARGS+=( "$1" )
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
      echo -e "${BASH_REMATCH[1]}|${BASH_REMATCH[2]}|${BASH_REMATCH[3]}"
    fi
    return 0
  else
    if [[ $quiet != "true" ]]; then
      warn "sshpipe: unable to get info - disconnected or not a shell on remote?"
    fi
    return 4
  fi
}

# usage: sshpipe_close <host>
# example: sshpipe_close my_host
# close a preexisting sshpipe
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

# usage: sshpipe_tx <host> [content]
# example: sshpipe_tx my_host hostname
sshpipe_tx() { # TODO: make it read from stdin
  local fdi
  fdi=13
  shift

  echo -e "$@" >&"$fdi"
}

# usage: sshpipe_rx <host>
# example: sshpipe_rx my_host | grep ' line ' | tee errors.txt
sshpipe_rx() {
  local fdo
  fdo=14
  shift

  while read -r -t 0.1 -u "$fdo" LINE; do
    echo "$LINE"
  done
}
