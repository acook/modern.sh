# PATHS
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
  mktemp -d "${1:-$(scriptname)}.XXXXXXXX"
}
