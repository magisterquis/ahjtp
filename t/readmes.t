#!/bin/ksh
#
# readmes.t
# Make sure every directory has a README.md
# By J. Stuart McMurray
# Created 20251201
# Last Modified 20251201

set -euo pipefail

. t/shmore.subr

# Work out the directories to search.
set -A DIRS $(find * -type d) .
tap_plan ${#DIRS[@]}

# Make sure every directory has a readme
for DIR in ${DIRS[@]}; do
        set +e
        [[ -f "$DIR/README.md" ]]
        tap_ok "$?" "$DIR has a README" "$0" $LINENO
        set -e
done

# vim: ft=sh
