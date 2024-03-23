## DATA
#
# Functions for data manipulation and inspection.

# usage: array_contains <needle> <haystack>
# example: array_contains "entry" "$list"
# !! BROKEN !!
array_contains () {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}



