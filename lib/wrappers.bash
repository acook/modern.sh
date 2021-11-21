# WRAPPERS
#
# These functions exist for wrapping around common use cases.

# usage: safe_cd <path>
# example: safe_cd /mnt/network_drive
# if cd fails then we should exit
# fixes a common shellcheck complaint
safe_cd() {
  say "entering directory \`$1\`"
  cd "$1" || die "safe_cd: couldn't change directory to \`$1\`";
}

# usage: command_exists <command_name>
# example: if command_exists lsb_release; lsb_release -ds; fi
# used in conditionals to determine presence of a command or executable
command_exists() { command -v "$1" > /dev/null 2>&1; }

# usage: run "title" <command> [args]
# example: run "compile" clang thing.c
# display command to run, confirm it exists, run it, output a warning on failure
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

# usage: run_or_die "title" <command> [args]
# example: run_or_die "download dependencies" curl -O package.pkg
# as run, but die if command missing or exits with an error
run_or_die() {
  say "running $1 command: \`${*:2}\`"
  command_exists "$2" || die "command \`$2\` not found"
  $2 "${@:3}" || die_status $? "$2 command"
}
