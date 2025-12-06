# build.mk
# Helpful makefile things
# By J. Stuart McMurray
# Created 20251201
# Last Modified 20251201

# call_make calls make to build $@ in another directory.
# It should be used like
# ../foo/bar! call_make
call_make: .USE
	${.MAKE} -C ${@D} ${@F}
	@echo \# Finished in ${@D}
