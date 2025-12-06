# Makefile
# Build the password store
# By J. Stuart McMurray
# Created 20251202
# Last Modified 20251202

.include "../../inc/build.mk"

FLAGS   = ../../flags.m4/flags.m4
UUIDGEN = ../../uuidgen/uuidgen

Dockerfile: ../../inc/files.m4 ../../inc/debian.m4 ${FLAGS} Dockerfile.m4
Dockerfile: passwordstore.c passwords_file key_file
	m4 -PEE\
		-Dm4_sources='${>:N*.m4}'\
		${>:M*.m4} >$@.tmp
	mv $@.tmp $@

${FLAGS} ${UUIDGEN}! call_make

key_file: ${FLAGS}
	echo m4_flag_PasswordStoreEncryptionKey |\
		m4 -PEE ${FLAGS} /dev/stdin >>$@.tmp
	mv $@.tmp $@

passwords_file.plaintext: ${FLAGS}
	> $@.tmp
	for i in `jot 9`; do\
		echo -n "user_$$i " >>$@.tmp;\
		${UUIDGEN}          >>$@.tmp;\
	done
	echo "admin  m4_flag_PasswordStoreEncryptedPassword" |\
		m4 -PEE ${FLAGS} /dev/stdin >>$@.tmp
	mv $@.tmp $@

passwords_file: passwordstore key_file passwords_file.plaintext
	./passwordstore -e key_file passwords_file.plaintext >$@.tmp
	mv $@.tmp $@

passwordstore: passwordstore.c
	${CC}\
		--pedantic\
		-O2\
		-Wall\
		-Werror\
		-Wextra\
		-o $@\
		${>:M*.c}

clean:
	rm -f\
		Dockerfile\
		key_file\
		passwords_file.plaintext\
		passwords_file\
		passwordstore
.PHONY: clean
