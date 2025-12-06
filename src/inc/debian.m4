m4_dnl debian.m4
m4_dnl FROM debian dockerfile chunk
m4_dnl By J. Stuart McMurray
m4_dnl Created 20251202
m4_dnl Last Modified 20251202
m4_define(m4_debian, `FROM debian AS debian
RUN  useradd -s /bin/bash -d /build build
RUN  mkdir --mode=0700 /build && chown build:build /build
ARG  DEBIAN_FRONTEND=noninteractive
RUN  apt-get -qy update && apt-get -qy upgrade
RUN  apt-get -qy install bash-static bmake build-essential curl libbsd-dev \
        pkgconf')m4_dnl
m4_dnl
m4_dnl vim: ft=dockerfile
