# Makefile
# Build cicd's Dockerfile
# By J. Stuart McMurray
# Created 20251130
# Last Modified 20251130

.include "../../inc/build.mk"

FLAGS   = ../../flags.m4/flags.m4
GENCERT = ../../gencert/gencert
UUIDGEN = ../../uuidgen/uuidgen

${FLAGS} ${GENCERT} ${UUIDGEN}! call_make

password: ${UUIDGEN}
	${UUIDGEN} >$@.tmp
	mv $@.tmp $@

sstls.txtar: ${GENCERT}
	${GENCERT} -filename $@ generate

Dockerfile: ../../inc/files.m4 ../../inc/debian.m4 ${FLAGS} Dockerfile.m4
Dockerfile: cicd.go ../../../go.mod ../../../go.sum sstls.txtar password
	m4 -PEE\
		-Dm4_password=$$(<password)\
		-Dm4_sources='${>:N*.m4}'\
		${>:M*.m4} >$@.tmp
	mv $@.tmp $@

clean:
	rm -f Dockerfile sstls.txtar cert_hash password
.PHONY: clean
