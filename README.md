A Hacker's Journey Through `/proc`
==================================
Material for a talk about `/proc` and hacking, presented at
- [BSides Dresden 2025](https://docs.google.com/presentation/d/1btvHtZYNFm0jaAggYvZQCLqLE0CXspBj1cswqZbcivc/edit?slide=id.g39a29d6818d_1_126#slide=id.g39a29d6818d_1_126)
- [Bsides Dublin 2026 (soon...)](https://docs.google.com/presentation/d/1qZBLvkyrqeW0EoTDVASi9uzWJ1kFq_Gtpdi1nL1KGTA/edit?slide=id.g3d5808b68a4_1_49#slide=id.g3d5808b68a4_1_49)

Helpful things:
- The [`src/`](./src) directory - Source code for most of the things in the talk
- [`compose.json`](./compose.json) - [CTF](#CTF) creation via `docker compose`
- [`user-data.sh`](./user-data.sh) - [CTF](#CTF) creation from a fresh Linux box
- [Curlrevshell](https://github.com/magisterquis/curlrevshell) - Shell over curl

For legal use only.

CTF
===
The talk more or less walks through a CTF, which may be set up using either
[`compose.json`](./compose.json) or [`user-data.sh`](./user-data.sh).

Something like solutions can be found in the [`pastables`](./pastables) used to
make the for the talk.

The curl one-liner should look like
```sh
curl                                                                   \
    -skT-                                                              \
    -u :6feaf10b-3d2a-485e-8319-dfd7c3849ec4                           \
    --expect100-timeout 0.1                                            \
    --pinnedpubkey sha256//zPRifE8BVFTsK0SR4R9wzPqaGVni6GGCqp2xt0wZV6U \
    https://$ADDR
```

### [`compose.json`](./compose.json)
With Docker and Docker Compose
[installed](https://docs.docker.com/engine/install/), send `compose.json` to
`docker compose`'s stdin with
```sh
docker compose \
    -f - \
    up \
    --build \
    --no-log-prefix \
    --quiet-build \
    <compose.json
```
One-liners to connect to will be printed after everything is built and sets
itself up, which may take a few minutes.

Works on Debian 13.  Probably on other Linux distributions as well.

### [`user-data.sh`](./user-data.sh)
Alternatively, a new cloud Linux instance may be spun up using
[`user-data.sh`](./user-data.sh) as the user data script for the new instance.
It should also work pretty well if just run on a (burnable) Linux host.

One-liners to connect will be in `/home/victim/curl_commands`.
