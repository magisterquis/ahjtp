#!/bin/ksh
#
# cicd.t
# Make sure our cicd tool works
# By J. Stuart McMurray
# Created 20251201
# Last Modified 20251204

set -euo pipefail

. t/shmore.subr
tap_plan 18

# Start the logger.
PASSWORD=p-$RANDOM
DUMMY= DEBUG_PASSWORD=$PASSWORD go run ./src/containers/cloud_logger \
        -debug-listen "127.0.0.1:0" \
        -log-listen   "127.0.0.1:0" \
        2>&1 |&
read -pr _ _ STARTING SPID LADDR DADDR DPASS REST
tap_is "$STARTING" "Starting" "Got Starting log line" "$0" $LINENO
tap_like "$SPID" '^Pid:\d+$' "PID log entry looks ok" "$0" $LINENO
tap_like \
        "$LADDR" '^LogAddress:127.0.0.1:\d+$' \
        "Log address log entry looks ok" \
        "$0" $LINENO
tap_like \
        "$DADDR" '^DebugAddress:127.0.0.1:\d+$' \
        "Debug address log entry looks ok" \
        "$0" $LINENO
tap_like \
        "$DPASS" '^DebugPassword:' \
        "Debug password log entry looks ok" \
        "$0" $LINENO
tap_is "$REST" "" "Nothing unexpected on first log line" "$0" $LINENO
SPID=${SPID#*:}
LPORT=$((${LADDR##*:}))
DPORT=$((${DADDR##*:}))
DPASS=${DPASS#*:}
tap_isnt "$LPORT" '0' "Log listen port looks ok"   "$0" $LINENO
tap_isnt "$DPORT" '0' "Debug listen port looks ok" "$0" $LINENO

# log_is reads a log line, ignoring the timestamp and source address, and
# checks it against $1.
# log_is emits one TAP line.
#
# Arguments:
# $0 - Script name
# $1 - What it should be
# $2 - $LINENO
log_is() {
        local _want=$1 _lineno=$2 _line
        read -pr _ _ _ _line
        tap_is "$_line" "$_want" "Got log - $_want" "$0" "$_lineno"
}

# Try a log connection.
GOT=$(date | nc -N 127.0.0.1 "$LPORT" 2>&1 ||:)
tap_ok  $?       "Sent a log line happily"        "$0" $LINENO
tap_is "$GOT" "" "Sent a log line with no errors" "$0" $LINENO
log_is "New log connection"      $LINENO
log_is "Finished log connection" $LINENO

# Try a debug connection.
MSG=m-$RANDOM
GOT=$( (echo $PASSWORD; echo echo $MSG) | nc -N 127.0.0.1 "$DPORT" 2>&1 ||:)
WANT="Debug password, please:
Password correct
$MSG"
log_is                "New debug connection"                  $LINENO
log_is                "Password correct (\"$PASSWORD\")"      $LINENO
log_is                "Finished debug connection"             $LINENO
tap_is "$GOT" "$WANT" "Debug output correct"             "$0" $LINENO

# Stop the server.
kill "$SPID"
wait
read -pr
tap_is "$REPLY" "signal: terminated" "Server exited" "$0" $LINENO
read -pr ||:
tap_is "$REPLY" "" "Got no more log lines" "$0" $LINENO

# vim: ft=sh
