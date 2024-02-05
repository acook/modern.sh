# NETWORK
#
# This contains functions that are useful for network operations.

# usage: txcp <host> <local_filename> <remote_filename>
# example: txcp me@example.com asciiart.txt motd.txt
# send a local file to a remote host using only SSH
txcp() {
    # shellcheck disable=SC2029
    ssh "$1" "cat > '$3'" < "$2"
}

# usage: rxcp <host> <remote_filename> <local_filename>
# example: txcp me@example.com garbage.bak davinci.dat
# send a local file to a remote host using only SSH
rxcp() {
  # shellcheck disable=SC2029
  ssh "$1" "cat $2" > "$3"
}
