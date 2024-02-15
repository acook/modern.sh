# UTILITY
#
# Functions which perform useful but more complex and less essential tasks.

# usage: <input> | nl_squeeze
# example: cat foo.txt | nl_squeeze
# squeezes newlines so that there are no more than 2 together
nl_squeeze() { awk 'BEGIN{RS="";ORS="\n\n"}1' ;}

# usage: <input> | no_emptylines
# example: cat foo.txt | no_emptylines
# removes empty lines and lines containing only spaces
no_emptylines() {
  sed '/^\s*$/d'
}

# usage: <input> | sh_comments [grep_args]
# example: cat foo.bash | sh_comments
# extracts only lines starting with an octothorpe
sh_comments() { \grep ${1:-} '^\s*#'; }

# usage: <input> | no_comments
# example: cat foo.bash | no_comments
# removes comments from scripts
no_comments() { sh_comments -v; }

# usage: <input> | stripscript
# removes comments and empty lines
stripscript() {
  no_comments | no_emptylines
}

# usage: strand [length] [charset]
# example: my_token="$(strand 16 'A-Za-z0-9!"#$%&\'()*+,-./:;<=>?@[\]^_`{|}~')"
# generates a random string
strand() {
  local len
  local charset
  len="${1:-8}"
  charset="${2:-A-Z0-9}"
  LC_ALL=C tr -dc "$charset" < /dev/urandom | head -c "$len"
}
