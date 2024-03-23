## DISPLAY
#
# This contains functions that are important for basic information output, color, and cursor movement.

# required by `say` for timestamps
#needs time

# usage: say <text>
# example: say 'articulating splines'
# intended for stdout logging and information about current actions
say()  {
  if [[ $MODERN_QUIET == "true" ]]; then
    echo -ne " -- $*\n";
  else
    echo -ne " -- ($(scriptname) @ $(ts)) : $*\n";
  fi
}

# usage: warn <text>
# example: warn 'that is one doomed space marine'
# same as `say` except it sends to stderr
warn() { say "$*" >&2; }

# usage: sayenv <VARNAME>
# example: sayenv path
# dump the name and contents of an environment variable in say format
sayenv() { say "$1=$(eval "echo -ne \$$1")"; }

# usage: colorfg <color>
# example: colorfg 97; echo "some lavendarish text"
# easily change the foreground (text) to one of 256 colors
# the 16 standard colors are also addressable by name
colorfg() {
  case "$1" in
  ("black") color=30 ;;
  ("red") color=31 ;;
  ("green") color=32 ;;
  ("yellow") color=33 ;;
  ("blue") color=34 ;;
  ("magenta") color=35 ;;
  ("cyan") color=36 ;;
  ("white") color=37 ;;

  ("green3") color="38;5;34" ;;
  ("red3") color="38;5;160" ;;
  ("orangered") color="38;5;202" ;;
  ("violet") color="38;5;128" ;;
  (*) color="38;5;$1" ;;
  esac
  echo -ne "\e[$color""m"
}

# usage: colorbg <color>
# example: colorbg 22; echo "text with a dark green background"
# easily change the foreground (text) to one of 256 colors
# the 16 standard colors are also addressable by name
colorbg() {
  case "$1" in
  ("black") color=40 ;;
  ("red") color=41 ;;
  ("green") color=42 ;;
  ("yellow") color=43 ;;
  ("blue") color=44 ;;
  ("magenta") color=45 ;;
  ("cyan") color=46 ;;
  ("white") color=47 ;;

  ("green3") color="48;5;34" ;;
  ("red3") color="48;5;160" ;;
  ("orangered") color="48;5;202" ;;
  ("violet") color="48;5;128" ;;
  (*) color="48;5;$1" ;;
  esac
  echo -ne "\e[$color""m"
}

# usage: colorreset
# example: echo "$(colorfg red)prompt> $(colorreset)"
# return console to default color settings
colorreset() {
  echo -ne "\e[0m"
}

# usage: ansigoto <column>
# example: echo overwrite this; ansigoto 0; echo blah blah blah
# move the cursor to a column on the current line
ansigoto() {
  echo -ne "\e[$1""G"
}

# usage: ansieol
# example: echo '| good for borders'; ansieol; echo '|'
# sends the cursor to the end of the line
ansieol() {
  echo -ne "\e[K"
}

# usage: ansiup <count>
# example: echo "loading..."; load file; ansiup 1; ansigoto 0; echo 'done!     '
# sends the cursor up the specified number of lines
ansiup() {
  echo -ne "\e[$1""A"
}

# usage: hilite <matcher> <style>
# example: echo "foo bar baz" | hilite bar $(colorfg green)
# highlights the matching text with the given style
hilite() {
    sed "s/$1/$2&$(colorreset)/g"
}
