#!/bin/ksh
#
# cicd.t
# Make sure our cicd tool works
# By J. Stuart McMurray
# Created 20251201
# Last Modified 20251201

set -euo pipefail

. t/shmore.subr

tap_plan 9

GREETING="g-$RANDOM"

# Start the server going.
PASSWORD=p-$RANDOM
TMPF=$(mktemp)
trap 'rm -f "$TMPF"; tap_done_testing' EXIT
go run ./src/containers/cicd \
        -debug-logfile "$TMPF" \
        -greeting "$GREETING" \
        -listen "127.0.0.1:0" \
        -password "$PASSWORD" \
        -shell "/bin/ksh" 2>&1 |&
read -pr _ _ _ SPID ADDR FP SPW
SPID=${SPID#Pid:}
ADDR=${ADDR#Address:}
FP=${FP#Fingerprint:}
SPW=${SPW#Password:}
tap_like "$SPID" '^\d+'                 "PID looks ok"         "$0" $LINENO
tap_like "$ADDR" '^127.0.0.1:\d+'       "Address looks ok"     "$0" $LINENO
tap_like "$FP"   '^[0-9A-Za-z+/]{43}=$' "Fingerprint looks ok" "$0" $LINENO
tap_is   "$SPW"  "$PASSWORD"            "Password set ok"      "$0" $LINENO
SPID=$((SPID))
tap_isnt "$SPID" 0 "PID isn't 0" "$0" $LINENO

# Make a request.
MSG=m-$RANDOM
GOT=$(echo "echo $MSG" | curl \
        --insecure \
        --pinnedpubkey "sha256//$FP" \
        --show-error \
        --silent \
        --upload-file - \
        --user "anything:$PASSWORD" \
        "https://$ADDR")
WANT="$GREETING
$MSG"
tap_is "$GOT" "$WANT" "Greeting and upload/execute worked" "$0" $LINENO

# Stop the server.
kill "$SPID"
wait
read -pr
tap_is "$REPLY" "signal: terminated" "Server exited" "$0" $LINENO
read -pr ||:
tap_is "$REPLY" "" "Got no more log lines" "$0" $LINENO

# Make sure logfile is gone.
set +e
[[ -f "$TMPF" ]]
RET=$?
set -e
tap_ok "$?" "Debug logfile deleted" "$0" $LINENO

# vim: ft=sh
