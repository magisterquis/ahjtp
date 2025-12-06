/*
 * passwordstore.c
 * Possibly the worst password store written
 * By J. Stuart McMurray
 * Created 20251202
 * Last Modified 20251202
 */

#include <sys/mman.h>
#include <sys/stat.h>

#include <err.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <strings.h>
#include <unistd.h>

#define xstr(s) str(s)
#define str(s) #s

#define PORT 8080

char *cryptf(const char *, const char *, size_t *);
char *map_file(const char *fn, size_t *size);

void
usage(void)
{
        printf("Usage: %s [-eu] [-v token] key_file passwords_file\n",
                        getprogname());
        printf("\n");
        printf("With -e, encrypts passwords.\n");
        printf("With -u, unlink the passwords file.\n");
        printf("Without, stores decrypted passwords in memory\n");
        printf("Well, ok, \"encryption\"...\n");
        exit(10);
}

int
main(int argc, char **argv)
{
        char    *key_file, *passwords_file, *passwords;
        int      ch, eflag, uflag;
        size_t   off, size;
        ssize_t  nw;

        ch = eflag = uflag = 0;

        /* Work out what we're doing. */
        while (-1 != (ch = getopt(argc, argv, "euv:"))) {
                switch (ch) {
                case 'e':
                        eflag = 1;
                        break;
                case 'u':
                        uflag = 1;
                        break;
                case 'v':
                        break;
                default:
                        usage();
                }
        }
        argc -= optind;
        argv += optind;

        /* At this point we can en/decrypt. */
        if (2 != argc) {
                usage();
        }
        key_file = argv[0];
        passwords_file = argv[1];
        passwords = cryptf(key_file, passwords_file, &size);

        /* And maybe unlink. */
        if (uflag)
                if (-1 == unlink(passwords_file))
                        err(15, "unlink %s", passwords_file);

        /* If we're not encrypting, we're not really doing much, are we? */
        if (!eflag)
                for (;;)
                        sleep(1024);
                        
        /* We're encrypting, so print the encrypted form. */
        for (off = 0; off < size; off += nw)
                if (0 == (nw = write(STDOUT_FILENO, passwords + off,
                                                size - off)) || -1 == nw)
                        err(14, "write");
        return 0;
}

/* map_file maps the file fn into memory.  The returned void * must be passed
 * to munmap(2) and returns the size in size..  The program is terminated on
 * error. */
char *
map_file(const char *fn, size_t *size)
{
        char        *ret;
        int          fd;
        struct stat  st;

        /* Open file. */
        if (-1 == (fd = open(fn, O_RDONLY)))
                err(11, "open %s", fn);

        /* Get its size. */
        bzero(&st, sizeof(st));
        if (-1 == fstat(fd, &st))
                err(12, "stat %d (%s)", fd, fn);
        *size = (size_t)st.st_size;


        /* Map into memory. */
        if (MAP_FAILED == (ret = (char *)mmap(NULL, *size, PROT_READ|PROT_WRITE,
                                        MAP_PRIVATE, fd, 0)))
                err(13, "mmap %d (%s)", fd, fn);

        close(fd);
        return ret;
}

/* cryptf opens the keyfile and passwords file and en/de-crypts the passwords.
 * The address of the passwords is returned and its size placed in size.
 * crypt terminates the program on failure. */
char *
cryptf(const char *key_file, const char *passwords_file, size_t *size)
{
        char    *key, *passwords;
        size_t   key_len, off;
        
        /* Get hold of our files. */
        key       = map_file(key_file, &key_len);
        passwords = map_file(passwords_file, size);

        /* "Encrypt" */
        for (off = 0; off < *size; ++off)
                passwords[off] ^= key[off % key_len];

        return passwords;
}

