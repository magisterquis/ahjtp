# Dockerfile
# Build the password store's container
# By J. Stuart McMurray
# Created 20251202
# Last Modified 20251202

# Running container
m4_debian
WORKDIR /build
m4_addfiles(m4_patsubst(m4_sources,` ',`,'))m4_dnl
RUN bmake \
            CFLAGS="$( pkgconf --cflags libbsd-overlay libbsd-ctor)" \
            LDFLAGS="$(pkgconf --libs   libbsd-overlay libbsd-ctor)" \
            passwordstore
CMD ["./passwordstore", "-u", \
        "-v", "m4_flag_PasswordStoreVectorToken", \
        "./key_file", "./passwords_file"]

# vim: ft=dockerfile
