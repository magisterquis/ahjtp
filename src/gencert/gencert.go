// Program gencert - Generates a self-signed cert with sstls
package main

/*
 * gencert.go
 * Generates a self-signed cert with sstls
 * By J. Stuart McMurray
 * Created 20251201
 * Last Modified 20251201
 */

import (
	"flag"
	"fmt"
	"log"
	"os"
	"path/filepath"

	"github.com/magisterquis/curlrevshell/lib/sstls"
)

func main() {
	/* Command-line flags. */
	var (
		fn = flag.String(
			"filename",
			"cert.txtar",
			"Txtar certificate `file`",
		)
	)
	flag.Usage = func() {
		fmt.Fprintf(
			os.Stderr,
			`Usage: %s [options] generate|hash

Generates or hashes a sstls self-signed cert and key.

Options:
`,
			filepath.Base(os.Args[0]),
		)
		flag.PrintDefaults()
	}
	flag.Parse()

	/* Make sure we have a file on which to operate. */
	if "" == *fn {
		log.Fatalf("Need a filename")
	}

	switch cmd := flag.Arg(0); cmd {
	case "generate":
		if _, err := generate(*fn); nil != err {
			log.Fatalf("Error: %s", err)
		}
	case "hash":
		fp, err := hash(*fn)
		if nil != err {
			log.Fatalf("Error: %s", err)
		}
		fmt.Printf("%s\n", fp)
	case "":
		log.Fatalf("Need something to do")
	default:
		log.Fatalf("Did not expect %s", cmd)
	}
}

// Generate generates a keypair and stores it in fn.
// The key's fingerprint is returned, for testing.
func generate(fn string) (string, error) {
	/* Generate the certificate. */
	cPEM, kPEM, cert, err := sstls.GenerateSelfSignedCertificate(
		"",
		nil,
		nil,
		0,
	)
	if nil != err {
		return "", fmt.Errorf("generating keypair: %w", err)
	}

	/* Write it to the output file. */
	if err := sstls.SaveCertificate(fn, cPEM, kPEM); nil != err {
		return "", fmt.Errorf("saving keypair to %s: %w", fn, err)
	}

	/* Return the fingerprint. */
	fp, err := sstls.PubkeyFingerprintTLS(cert)
	if nil != err {
		return "", fmt.Errorf("getting fingerprint: %w", err)
	}
	return fp, nil
}

// Hash reads the keypair from fn and prints a fingerprint to stdout.
func hash(fn string) (string, error) {
	/* Load the keypair. */
	cert, err := sstls.LoadCachedCertificate(fn)
	if nil != err {
		return "", fmt.Errorf("loading %s: %w", fn, err)
	}

	/* Print its hash. */
	fp, err := sstls.PubkeyFingerprintTLS(cert)
	if nil != err {
		return "", fmt.Errorf("getting fingerprint: %w", err)
	}

	return fp, nil
}
