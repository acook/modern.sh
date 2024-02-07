#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/array.bash"

anew foo
aunshift foo "a"
echo "foo=${foo[*]}"
aappend foo "b"
echo "foo=${foo[*]}"

alist bar 1 2 3 4
echo "bar=${bar[*]}"

aconcat foo $bar
echo "foo=${foo[*]}"

acontains foo "b" && echo yes || echo no
