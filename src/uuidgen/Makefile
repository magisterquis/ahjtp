# Makefile
# Fetch/Build uuidgen
# By J. Stuart McMurray
# Created 20251201
# Last Modified 20251201

BASEURL=https://raw.githubusercontent.com/magisterquis/uuidgen-openbsd/refs/heads/master/

.include "../inc/build.mk"

src/uuidgen.c: add_readme
	@mkdir -p src/
	ftp -M -o $@ -u -V ${BASEURL}/${@F}

src/makefile: add_readme
	@mkdir -p src/
	ftp -M -o $@ -u -V ${BASEURL}/Makefile

add_readme: .USE
	@echo Mooched from ${BASEURL} >src/README.md

src/uuidgen: src/uuidgen.c src/makefile call_make

uuidgen: src/uuidgen
	cp $> $@

clean:
	rm -rf uuidgen src/
