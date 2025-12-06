gencert
=======
Generates a self-signed cert and key with
[`sstls`](https://pkg.go.dev/github.com/magisterquis/curlrevshell/lib/sstls).

Quickstart
----------
1.  Build
2.  Generate a cert and key
    ```sh
    gencert generate
    ls -l ./cert.txtar
    -rw-------  1 you  you  820 Dec  1 15:30 ./cert.txtar
    ```
3.  Get the cert's hash
    ```sh
    gencert hash
    # DYypujuuJOBvj6QHPchi4NnpwJp+N6QA8TxTcXlVlq8=
    ```

Usage
-----
```
Usage: gencert [options] generate|hash

Generates or hashes a sstls self-signed cert and key.

Options:
  -filename file
    	Txtar certificate file (default "cert.txtar")
```
