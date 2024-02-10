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

# usage: sshpipe_new <host>
# example: my_pipe="$(sshpipe_new my_host | tail -n 1)"
# create a named pipe to send bash commands to remote host
sshpipe_new() { # manage multiple file descriptors
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

  mkfifo "$in" "$out"
  ssh -tt "$remote" < "$in" > "$out" &
  echo "$!" > "$pid"
  eval "exec $fdi>$in"
  eval "exec $fdo<$out"
  echo "$remote.$fdi"
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

  eval "exec $fdi>&-"
  eval "exec $fdo>&-"
  kill "$(< "$pid")"
  echo "$pid"
  rm -v "$in" "$out" "$pid"
}

# usage: sshpipe_tx <host> [content]
# example: sshpipe_tx my_host hostname
sshpipe_tx() { # TODO: make it read from stdin
  local fd
  fd=13

  echo "$@" >&"$fd"
}

# usage: sshpipe_rx <host>
# example: sshpipe_rx my_host | grep ' line ' | tee errors.txt
sshpipe_rx() {
  local fdo
  fdo=14

  while read -r -t 0.1 -u "$fdo" LINE; do
    echo "$LINE"
  done
}
