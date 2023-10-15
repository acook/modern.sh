# INIT
#
# Basic initialization.
# Don't overwrite these values manually.

set -o nounset

if [[ -z ${_BASH_SHARED_LIB+unset} ]]; then
  declare -a _BASH_SHARED_LIB
  _BASH_SHARED_LIB=("$(readlink -e "${BASH_SOURCE[0]}")")
else
  return 0
fi

echo " -- ($(basename "$(dirname "$(readlink -m "${BASH_SOURCE[-1]}")")")/$(basename "${BASH_SOURCE[-1]}") @ $(date "+%Y-%m-%d %T")) : setting up..." >&2
