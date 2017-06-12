#!/bin/bash -l

# Get source directory of this script
export STAGED_ROOT="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

# Change working directory to user's home directory
cd "${HOME}"

# Start up desktop
"${STAGED_ROOT}/desktops/${DESKTOP}.sh"
