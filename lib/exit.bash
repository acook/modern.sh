## EXIT
#
# Functions for exiting with messages.

# requires say and warn functions for messaging
#needs display
# require scriptsame to know how to exit
#needs script

# usage: ok <message>
# example: ok 'all good!'
# formatted success message and exit
# message is optional
ok()   { say "\e[32m(ok) $*\e[0m"; exit 0; }

# usage: die <message>
# example: die 'hit the road jack'
# formatted failure message and exit
# message is optional
die()  { warn "\e[31m(die) $*\e[0m"; exit 1; }

# usage: die_status <status> [message]
# example: die_status 255 "file not found"
# formatted failure message and exit with specified status code
die_status() { warn "\e[31m(died with status code $1) ${*:2}\e[0m"; exit "$1"; }

# usage: quit_status <status> [message]
# example: quit_status $? "last command exited"
# automatically selects the correct exit function based on context
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
