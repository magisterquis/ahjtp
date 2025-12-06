package main

/*
 * gencert_test.go
 * Tests for gencert.go
 * By J. Stuart McMurray
 * Created 20251201
 * Last Modified 20251201
 */

import (
	"path/filepath"
	"testing"
)

func Test_gencert(t *testing.T) { t.Skipf("TODO: Finish This") }

func Test(t *testing.T) {
	fn := filepath.Join(t.TempDir(), "ct")

	/* Can we make a certificate? */
	gfp, err := generate(fn)
	if nil != err {
		t.Fatalf("Error generating certificate: %s", err)
	}

	/* Can we read it again? */
	rfp, err := hash(fn)
	if nil != err {
		t.Fatalf("Reading certificate: %s", err)
	}

	if gfp != rfp {
		t.Errorf(
			"Fingerprint mismatch:\n"+
				"generated: %s\n"+
				"     read: %s",
			gfp,
			rfp,
		)
	}
}
