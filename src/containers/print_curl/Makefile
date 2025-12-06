# Makefile
# Build the curl-printing Dockerfile
# By J. Stuart McMurray
# Created 20251201
# Last Modified 20251202

.include "../../inc/build.mk"

GENCERT       = ../../gencert/gencert
PASSWORD_FILE = ../cicd/password
SSTLS_TXTAR   = ../cicd/sstls.txtar

${GENCERT} ${PASSWORD_FILE} ${SSTLS_TXTAR}! call_make

cert_hash: ${GENCERT} ${SSTLS_TXTAR}
	${GENCERT} -filename ${SSTLS_TXTAR} hash >$@.tmp
	mv $@.tmp $@

print_curl.sh: print_curl.sh.m4
print_curl.sh: cert_hash ${PASSWORD_FILE} 
	m4 -PEE\
		-Dm4_hash=$$(<cert_hash)\
		-Dm4_password=$$(<${PASSWORD_FILE})\
		${>:M*.m4} >$@.tmp
	mv $@.tmp $@

Dockerfile: ../../inc/files.m4 ../../inc/debian.m4 Dockerfile.m4
Dockerfile: print_curl.sh
	m4\
		-PEE\
		-Dm4_sources=print_curl.sh\
		${>:M*.m4} >$@.tmp
	mv $@.tmp $@

clean:
	rm -f Dockerfile cert_hash print_curl.sh
.PHONY: clean
