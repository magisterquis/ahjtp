# Dockerfile
# Print the curl command needed to connect to the target
# By J. Stuart McMurray
# Created 20251201
# Last Modified 20251202

# Print the curl command info
m4_debian
m4_addfiles(m4_patsubst(m4_sources,` ',`,'))m4_dnl
CMD ["sh", "print_curl.sh"]

# vim: ft=dockerfile
