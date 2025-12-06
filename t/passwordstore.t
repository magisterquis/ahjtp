#!/bin/ksh
#
# cicd.t
# Make sure our cicd tool works
# By J. Stuart McMurray
# Created 20251202
# Last Modified 20251202

set -euo pipefail

. t/shmore.subr
tap_plan 5

SRCDIR=./src/containers/passwordstore
BINNAME=passwordstore
KEYNAME=key_file
BIN=$SRCDIR/$BINNAME
KEY=$SRCDIR/$KEYNAME
TMPD=$(mktemp -d)
PASSWORDS=$TMPD/passwords_file
ENCPASSWORDS=$PASSWORDS.enc
cp "$0" "$PASSWORDS"
PASSWORDSMD5=$(md5 <"$PASSWORDS")
trap 'rm -rf "$TMPD"; tap_done_testing' EXIT

# Make sure our program and key file build
make -C "$SRCDIR" "$BINNAME" "$KEYNAME" >/dev/null
tap_pass "Have $BINNAME and $KEYNAME"

# Can we encrypt a file?
"$BIN" -e "$KEY" "$PASSWORDS" >"$ENCPASSWORDS"
tap_pass "Encrypted $@"

# Did it at least change?
GOT=$(cat "$ENCPASSWORDS" | md5)
tap_isnt "$GOT" "$PASSWORDSMD5" "Encryption changed data" "$0" $LINENO

# Does it decrypt nicely?
GOT=$("$BIN" -u -e "$KEY" "$ENCPASSWORDS" | md5)
tap_is "$GOT" "$PASSWORDSMD5" "Double-encryption is decryption" "$0" $LINENO

# And was it removed?
set +e
[[ -f "$ENCPASSWORDS" ]]
RET=$?
set -e
tap_isnt "$RET" 0 "Passwords file removed" "$0" $LINENO

# vim: ft=sh
