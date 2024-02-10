# TIME
#
# Time-related functions.

# usage: ts
# example: echo "The time is $(ts)
#   local timestamp for output
ts()      { date "+%Y-%m-%d %T"; }

# usage: ts_file
# example: curl package.pkg -o "package_$(ts_file).pkg"
# timestamp for filenames, in UTC for consistency
ts_file() { date --utc "+%Y-%m-%d-%H-%M-%S"; }

# usage: ts_unix
# example: start_time="$(ts_unix)"
# unix timestamp with nanoseconds
# required by elapsed()
ts_unix() { date "+%s.%N"; }

# usage: elapsed <start_time> <end_time>
# takes two unix timestamps with nanoseconds
# returns the difference in human-readable format
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

