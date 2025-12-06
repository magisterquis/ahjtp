# Makefile
# Build the user-data script
# By J. Stuart McMurray
# Created 20251204
# Last Modified 20251204

.include "../inc/build.mk"

COMPOSE_B64 = ../compose.json/compose.json.b64

user-data.sh: user-data.sh.m4 ${COMPOSE_B64}
	m4 -PEE -Dm4_compose_b64=${COMPOSE_B64} ${>:M*.m4} >$@.tmp
	mv $@.tmp $@

${COMPOSE_B64}! call_make

clean:
	rm -f user-data.sh
.PHONY: clean
