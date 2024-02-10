# UTILITY
#
# Functions which perform useful but more complex and less essential tasks.

# usage: <input> | nl_squeeze
# example: cat foo.txt | nl_squeeze
# removes duplicate spaces
nl_squeeze() { awk 'BEGIN{RS="";ORS="\n\n"}1' ;}

# usage: <input> | sh_comments [grep_args]
# example: cat foo.bash | sh_comments
# extracts only lines starting with an octothorpe
sh_comments() { \grep ${1:-} '^\s*#'; }

# usage: <input> | no_comments
# example: cat foo.bash | no_comments
# removes comments from scripts
no_comments() { sh_comments -v; }

# usage: <input> | stripscript
# removes comments and condenses newlines
stripscript() {
  no_comments | nl_squeeze
}
