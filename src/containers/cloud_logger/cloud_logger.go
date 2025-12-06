// Program cloud_logger - Hipster-Friendly Cloud-based Logger
package main

/*
 * cloud_logger.go
 * Hipster-Friendly Cloud-based Logger
 * By J. Stuart McMurray
 * Created 20251201
 * Last Modified 20251201
 */

import (
	"bytes"
	"context"
	"flag"
	"fmt"
	"io"
	"log"
	"net"
	"os"
	"os/exec"
	"path/filepath"

	"github.com/magisterquis/curlrevshell/lib/ctxerrgroup"
)

// DebugPasswordEnvVar is the environment variable in which we expect the
// password for debugging connections.
const DebugPasswordEnvVar = "DEBUG_PASSWORD"

// Shell is the shell to run.  It can be overridden at compile-time.
var Shell = "/bin/sh"

func main() {
	/* Command-line flags. */
	var (
		lAddr = flag.String(
			"log-listen",
			"0.0.0.0:80",
			"Log listen `address`",
		)
		dAddr = flag.String(
			"debug-listen",
			"0.0.0.0:1099",
			"Debug listen `address`",
		)
		_ = flag.String(
			"token",
			"",
			"Just here to make a flag work",
		)
	)
	flag.Usage = func() {
		fmt.Fprintf(
			os.Stderr,
			`Usage: %s [options]

Hipster-Friendly Cloud-based Logger.

To debug the container, netcat to the debug port and give the password passed
in the DEBUG_PASSWORD environment variable.

Options:
`,
			filepath.Base(os.Args[0]),
		)
		flag.PrintDefaults()
	}
	flag.Parse()

	log.SetOutput(os.Stdout)

	/* Get the debug password from the environment. */
	debugPass := os.Getenv(DebugPasswordEnvVar)

	/* Start listeners. */
	ll, err := net.Listen("tcp", *lAddr)
	if nil != err {
		log.Fatalf("Could not listen for logs on %s: %s", *lAddr, err)
	}
	dl, err := net.Listen("tcp", *dAddr)
	if nil != err {
		log.Fatalf(
			"Could not listen for debug commands on %s: %s",
			*dAddr,
			err,
		)
	}
	log.Printf(
		"Starting Pid:%d LogAddress:%s "+
			"DebugAddress:%s DebugPassword:%s",
		os.Getpid(),
		ll.Addr(),
		dl.Addr(),
		debugPass,
	)

	/* Handle connections. */
	eg, ctx := ctxerrgroup.WithContext(context.Background())
	handleConns := func(
		ctx context.Context,
		l net.Listener,
		h func(context.Context, net.Conn, string) error,
	) error {
		for {
			/* Pop a client and handle. */
			c, err := l.Accept()
			if nil != err {
				return fmt.Errorf("accept: %w", err)
			}
			eg.GoContext(ctx, func(ctx context.Context) error {
				defer c.Close()
				return h(ctx, c, debugPass)
			})
		}
	}
	eg.GoTag(ctx, "error_watcher", func(ctx context.Context) error {
		defer ll.Close()
		defer dl.Close()
		<-ctx.Done()
		return nil
	})
	eg.GoTag(ctx, "log_listener", func(ctx context.Context) error {
		return handleConns(ctx, ll, handleLogConn)
	})
	eg.GoTag(ctx, "debug_listener", func(ctx context.Context) error {
		return handleConns(ctx, dl, handleDebugConn)
	})

	log.Fatalf("Error: %s", eg.Wait())
}

// handleLogConn handles a connection for logging.
func handleLogConn(ctx context.Context, c net.Conn, password string) error {
	log.Printf("[%s] New log connection", c.RemoteAddr())
	defer log.Printf("[%s] Finished log connection", c.RemoteAddr())
	done := make(chan struct{})
	defer close(done)
	go func() {
		defer c.Close()
		select {
		case <-done:
		case <-ctx.Done():
		}
	}()
	io.Copy(io.Discard, c)
	return nil
}

// handleDebugConn handles a connection for debugging.
func handleDebugConn(ctx context.Context, c net.Conn, password string) error {
	log.Printf("[%s] New debug connection", c.RemoteAddr())
	defer log.Printf("[%s] Finished debug connection", c.RemoteAddr())
	/* Prompt for a password. */
	fmt.Fprintf(c, "Debug password, please:\n")
	/* Get the first line. */
	var (
		line = new(bytes.Buffer)
		buf  = make([]byte, 1)
	)
	for {
		/* Get a byte. */
		nr, err := c.Read(buf)
		if nil != err {
			log.Printf(
				"[%s] Error reading password: %s",
				c.RemoteAddr(),
				err,
			)
			return nil
		}
		/* Done if it's a newline. */
		if '\n' == buf[0] {
			break
		}
		/* Save this chunk of password. */
		line.Write(buf[:nr])
	}
	/* Make sure the password is correct. */
	if got, want := line.String(), password; got != want {
		fmt.Fprintf(c, "Password incorrect\n")
		log.Printf(
			"[%s] Password incorrect (got:%q want:%q)",
			c.RemoteAddr(),
			got,
			want,
		)
		return nil
	}
	/* All good, hook up to a shell. */
	fmt.Fprintf(c, "Password correct\n")
	log.Printf("[%s] Password correct (%q)", c.RemoteAddr(), password)
	sh := exec.CommandContext(ctx, Shell)
	sh.Stdin = c
	sh.Stdout = c
	sh.Stderr = c
	if err := sh.Run(); nil != err {
		log.Printf("[%s] Debug session error: %s", c.RemoteAddr(), err)
		fmt.Fprintf(c, "\nError: %s\n", err)
	}

	return nil
}
