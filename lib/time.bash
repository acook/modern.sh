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
