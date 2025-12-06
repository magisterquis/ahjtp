# Makefile
# Build compose.json
# By J. Stuart McMurray
# Created 20251201
# Last Modified 20251201

.include "../inc/build.mk"

COMPOSE_JSON  = compose.json
DOCKERFILES  != find ../containers -mindepth 1 -maxdepth 1 -type d
DOCKERFILES  := ${DOCKERFILES:S,$,/Dockerfile,}

# Make Dockerfiles and make them available to jq.
.for D in ${DOCKERFILES}
# Make sure the Dockerfile is up to date.
$D! call_make
# Make the Dockerfile available to jq.
JQVARS += --rawfile ${D:H:T} $D
.endfor

# The main thing.
${COMPOSE_JSON}: compose.jq ${DOCKERFILES}
	jq\
		--from-file ${>:M*.jq}\
		${JQVARS}\
		--null-input\
		>$@.tmp
	mv $@.tmp $@

${COMPOSE_JSON}.b64: ${COMPOSE_JSON}
	openssl base64 -e <$> >$@.tmp
	mv $@.tmp $@

clean:
	rm -f ${COMPOSE_JSON} ${COMPOSE_JSON}.b64
.PHONY: clean
