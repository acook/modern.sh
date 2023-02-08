# ARRAY
#
# Functions to make working with arrays and array-like data less painful.

# Bash Array Quick Reference:
#
# Bash Pointer Quick Reference:
# - `${!foo}` dereference foo, eg looks in the environment for a variable of the name stored in foo
# - `declare -n bar=baz` make bar new pointer to baz by name, now $bar can used anywhere $baz could be

# create an array variable by name
anew() {
    local aname=$1
    declare -a "$aname"
    export "$aname"
}

# create an array variable by name from a list of arguments
alist() {
    local aname=$1
    declare -a "$aname"
    declare -n ptr="$aname"
    ptr+=${*:2}
}

# add a single value to the beginning of an array
aunshift() {
    local array=$1
    local ptr
    local item=$2
    declare -n ptr="$array"
    ptr=("$item" "${array[*]}")
}

# add single value to end of an array
aappend() {
    local array=$1
    local item=$2
    declare -n ptr="$array"

    ptr+=("$item")
}

# combine two arrays
aconcat() {
    local left=$1
    local right=$2
    left+=$right
}

acontains() {
    local haystack=$1
    local needle=$2

    [[ " ${haystack[*]} " == *" ${needle} "* ]]
}
