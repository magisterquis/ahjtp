# Makefile
# Build cloud_logger's Dockerfile
# By J. Stuart McMurray
# Created 20251130
# Last Modified 20251130

.include "../../inc/build.mk"

FLAGS = ../../flags.m4/flags.m4

${FLAGS}! call_make

Dockerfile: ../../inc/files.m4 ../../inc/debian.m4 ${FLAGS} Dockerfile.m4 
Dockerfile: cloud_logger.go ../../../go.mod ../../../go.sum
	m4 -PEE\
		-Dm4_sources='${>:N*.m4}'\
		${>:M*.m4} >$@.tmp
	mv $@.tmp $@

clean:
	rm -f Dockerfile 
