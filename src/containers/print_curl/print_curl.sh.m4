#!/bin/sh
# 
# print_curl.sh
# Print curl one-liners
# By J. Stuart McMurray
# Created 20251202
# Last Modified 20251202

EXTADDR=$(curl -sm3 https://ipv4.icanhazip.com)
echo "----- Curl Commands for Access -----"
for ADDR in $(hostname -I) $(hostname) $NOTADDR; do
        echo "echo id | curl -skT- -u :m4_password --expect100-timeout 0.1 --pinnedpubkey sha256//m4_hash https://$ADDR"
done | sort -u
echo "--------- Adjust as needed ---------"

# vim: ft=sh
