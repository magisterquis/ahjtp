# Dockerfile
# Build cicd's container
# By J. Stuart McMurray
# Created 20251130
# Last Modified 20251130

# Build the server binary
FROM golang AS go-build
WORKDIR /build
m4_addfiles(m4_patsubst(m4_sources,` ',`,'))m4_dnl
RUN CGO_ENABLED=0 go build \
        -trimpath \
        -ldflags "-w -s \
                -X main.DebugFileFlag=m4_flag_LoggerDebugFile \
                -X main.ContrivedHiddenFlag=m4_flag_ContrivedCICDBinaryFlag \
                -X main.LoggerDebugAddr=cloud_logger:1099" \
        -o cicd

# Running container
m4_debian
RUN  mkdir --mode=0700 --parents /build/.cache/sstls &&\
       chown --recursive build:build /build
COPY --from=go-build --chown=build:build --chmod=0755 /build/cicd /build/cicd
COPY --from=go-build --chown=build:build --chmod=0600 \
       /build/sstls.txtar /build/.cache/sstls/cert.txtar
COPY                 --chown=build:build --chmod=0755 <<_eof /build/start.sh
#!/bin/sh
exec /build/cicd -rm-bin -greeting 'Welcome! m4_flag_Greeting' \\
        -password m4_password -token m4_flag_CICDVectorToken
_eof
USER build
ENV  LOGGER_DEBUG_CMD_PASSWORD=m4_flag_CloudLoggerDebugPassword
CMD  ["/build/start.sh"]

# vim: ft=dockerfile
