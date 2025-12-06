# Dockerfile
# Build cloud_logger's container
# By J. Stuart McMurray
# Created 20251130
# Last Modified 20251130

# Build the server binary
FROM golang AS go-build
WORKDIR /build
m4_addfiles(m4_patsubst(m4_sources,` ',`,'))m4_dnl
RUN CGO_ENABLED=0 go build \
        -trimpath \
        -ldflags "-w -s -X main.Shell=/sh" \
        -o cloud_logger

# Get static bash
m4_debian

# Running container
FROM   scratch
COPY   --from=go-build --chown=root:root --chmod=0755 /build/cloud_logger  /
COPY   --from=debian   --chown=root:root --chmod=0755 /usr/bin/bash-static /sh
COPY                   --chown=root:root --chmod=0755 <<_eof               /run
#!/sh
>/run && exec /cloud_logger -token m4_flag_LoggerVectorToken
_eof
EXPOSE 80/tcp 1099/tcp
ENV    DEBUG_PASSWORD=m4_flag_CloudLoggerDebugPassword
CMD    ["/run"]

# vim: ft=dockerfile
