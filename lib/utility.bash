# UTILITY
#
# Functions which perform useful but more complex and less essential tasks.

# usage: elapsed <start_time> <end_time>
# takes two unix timestamps with nanoseconds
# returns the difference in human-readable format
elapsed() {
  started_at=$1
  ended_at=$2

  if [[ -x $(which bc) ]]; then
    dt=$(echo "$ended_at - $started_at" | bc)
    dd=$(echo "$dt/86400" | bc)
    dt2=$(echo "$dt-86400*$dd" | bc)
    dh=$(echo "$dt2/3600" | bc)
    dt3=$(echo "$dt2-3600*$dh" | bc)
    dm=$(echo "$dt3/60" | bc)
    ds=$(echo "$dt3-60*$dm" | bc)

    printf " -- time elapsed: %d:%02d:%02d:%02.4f\n" "$dd" "$dh" "$dm" "$ds"
  else
    warn "START: $started_at"
    warn "END: $ended_at"
  fi
}

