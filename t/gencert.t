#!/bin/ksh
#
# gencert.t
# Make sure gencert works
# By J. Stuart McMurray
# Created 20251201
# Last Modified 20251201

set -euo pipefail

. t/shmore.subr

tap_plan 4

TMPF=$(mktemp)
trap 'rm -f $TMPF; tap_done_testing' EXIT

# Can we generate and hash a certificate?
GOT=$(go run ./src/gencert -filename "$TMPF" generate)
SIZE=$(($(wc -c <$TMPF)))
HASH=$(go run ./src/gencert -filename "$TMPF" hash)
tap_pass                                "Generated happily"        "$0" $LINENO
tap_is   "$GOT"  ""                     "Generated with no output" "$0" $LINENO
tap_isnt "$SIZE" "0"                    "Certificate isnt empty"   "$0" $LINENO
tap_like "$HASH" '^[0-9A-Za-z+/]{43}=$' "Hash looks like a hash"   "$0" $LINENO

# vim: ft=sh
