# COMPATIBILITY
#
# Functions that support running in different environments while retaining functionalit.

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
