## COMPATIBILITY
#
# Shell polyfills to ensure functionality across different environments.

# usage: gfix <command> <opts>
# example: gfix readlink -m .
# will try to prefix the command with a g, as homebrew and other non-native tools providing gnu userspace tools tend to do
# newer versions of macOS have broken the ability to reliably modify the path in subshells meaning that even if you include the homebrew path it may not find them
gfix() {
  if command_exists "g$1"; then
    "g$1" "${@:2}"
  else
    "$1"
  fi
}

# attempt to use gnu userspace on macOS if available
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
