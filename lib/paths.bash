## PATHS
#
# Helpers for finding and working with paths and filenames.

# usage: resolvepath <path>
# attempts to resolve all symlinks until the origin path is discovered
# circular symlinks will keep it looping forever
# see also: `man realpath(1)` on some systems
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

# simple way to get the path of the running file
thisdir() {
  dirname -- "$(scriptcaller)"
}

# usage: tmpdir: [prefix]
# example: my_temp_folder="$(tmpdir)"
# creates a temporary directory as defined by the system
# if no prefix supplied it will use the name of the running script
tmpdir() {
  mktemp -d "${1:-$(scriptname)}.XXXXXXXX" -t # without the -t it will create it in $PWD
}

# usage: fd_check <fd>
# example: if fd_check 14; then echo "the fd is open"; fi
# checks if a file descriptor is open
# doesn't work for fd 2 because it needs to capture possible error messages
fd_check() {
  local fd
  fd="$1"
  { true >&"$fd"; } 2>&-
}

# usage: pid_check <pid> [-p]
# example: if pid_check 29846; then echo "process is up"; fi
# non-blocking process status check
# returns 0 if process is live
# returns 255 and if -p it prints the processes exit status if dead
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
