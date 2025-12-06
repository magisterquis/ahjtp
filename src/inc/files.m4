m4_dnl files.m4
m4_dnl Macros to insert files
m4_dnl By J. Stuart McMurray
m4_dnl Created 20251130
m4_dnl Last Modified 20251130
m4_define(m4_addfile,
RUN echo `m4_esyscmd(openssl base64 -A -e <$1)' | base64 -d >`m4_regexp(`$1', `([^/]+$)', `\1')'
)m4_dnl
m4_define(m4_addfiles, `m4_ifelse(
        $#, 0, ,
        $#, 1, m4_addfile($1),
        `m4_addfile($1)m4_addfiles(m4_shift($@))m4_dnl'
)')m4_dnl
