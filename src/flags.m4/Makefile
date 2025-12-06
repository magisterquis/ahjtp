# Makefile
# Build the flags macro file
# By J. Stuart McMurray
# Created 20251201
# Last Modified 20251201

.include "../inc/build.mk"

UUIDGEN = ../uuidgen/uuidgen

${UUIDGEN}! call_make

flags.m4: ${UUIDGEN} flaglist flags.m4.in # Ok, this is kinda silly, yeah.
	m4 -PEE\
		-Dm4_uuidgen=${UUIDGEN}\
		-Dm4_flaglist=flaglist\
		${>:M*.in} >$@.tmp
	mv $@.tmp $@

clean:
	rm -f flags.m4
