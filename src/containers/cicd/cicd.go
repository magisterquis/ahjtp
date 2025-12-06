// Program cicd - CI/CD program which takes shell scripts via HTTPS POST
// requests
package main

/*
 * cicd.go
 * CI/CD program which takes shell scripts via HTTPS POST requests
 * By J. Stuart McMurray
 * Created 20251201
 * Last Modified 20251201
 */

import (
	"bytes"
	"flag"
	"fmt"
	"io"
	"log"
	"net"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"time"

	"github.com/magisterquis/curlrevshell/lib/sstls"
)

const (
	// LoggerDebugPasswordEnvVar is the environment variable with the
	// password needed to debug the logger.
	LoggerDebugPassEnvVar = "LOGGER_DEBUG_CMD_PASSWORD"
)

var (
	// DebugFileFlag is stuck in the debug output file
	DebugFileFlag string
	// ContrivedHiddenFlag is a flag hidden in the binary for contrived
	// reasons.
	ContrivedHiddenFlag string
	// LoggerDebugAddr is where we connect to the logger's debug port
	LoggerDebugAddr string
)

func main() {
	/* Command-line flags. */
	var (
		lAddr = flag.String(
			"listen",
			"0.0.0.0:4433",
			"Listen `address`",
		)
		shell = flag.String(
			"shell",
			"/bin/bash",
			"Shell `path`",
		)
		password = flag.String(
			"password",
			"",
			"HTTP basic auth `password`",
		)
		greeting = flag.String(
			"greeting",
			"",
			"Optional `greeting` message for new connections",
		)
		rmBin = flag.Bool(
			"rm-bin",
			false,
			"Remove the binary, for security",
		)
		_ = flag.String(
			"token",
			"",
			"Just here to make a flag work",
		)
		debugLogfile = flag.String(
			"debug-logfile",
			"/tmp/debug.out",
			"Output from logger debug session",
		)
	)
	flag.Usage = func() {
		fmt.Fprintf(
			os.Stderr,
			`Usage: %s [options]

CI/CD program which takes shell scripts via HTTPS POST requests

A connection to the logger's debug port can be made by setting
LOGGER_DEBUG_CMD_ADDR and LOGGER_DEBUG_PASSWORD.  Output will be logged to
/tmp/debug.out.

Options:
`,
			filepath.Base(os.Args[0]),
		)
		flag.PrintDefaults()
	}
	flag.Parse()

	log.SetOutput(os.Stdout)

	/* Remove our own binary, for security. */
	if *rmBin {
		path, err := os.Executable()
		if nil != err {
			log.Fatalf("Cannot get our own path: %s", err)
		}
		if err := os.Remove(path); nil != err {
			log.Fatalf(
				"Cannot remove our own binary %s: %s",
				path,
				err,
			)
		}
	}

	/* Print the hidden flag, maybe, but mostly so it's not optimized
	out of the binary. */
	if 1024 == time.Now().Unix() {
		log.Printf("%s", ContrivedHiddenFlag)
	}

	/* Start listening. */
	l, err := sstls.Listen(
		"tcp",
		*lAddr,
		"",
		0,
		sstls.DefaultCertFile(),
	)
	if nil != err {
		log.Fatalf("Error listening on %s: %s", *lAddr, err)
	}
	log.Printf(
		"Starting Pid:%d Address:%s Fingerprint:%s Password:%s",
		os.Getpid(),
		l.Addr().String(),
		l.Fingerprint,
		*password,
	)

	/* Try to connect to the stack trace server, if we have one. */
	go loggerDebug(*debugLogfile)

	/* Serve HTTPS clients. */
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		/* Make sure the password's correct. */
		if _, p, _ := r.BasicAuth(); p != *password {
			http.Error(
				w,
				http.StatusText(http.StatusUnauthorized),
				http.StatusUnauthorized,
			)
			return
		}
		/* For shells. */
		rc := http.NewResponseController(w)
		rc.EnableFullDuplex()
		/* Send a greeting, if we have one. */
		if "" != *greeting {
			fmt.Fprintf(w, "%s\n", *greeting)
		}
		rc.Flush()
		/* Hook up to a shell. */
		sh := exec.Command(*shell)
		sh.Stdin = r.Body
		sh.Stdout = w
		sh.Stderr = w
		if err := sh.Run(); nil != err {
			fmt.Fprintf(w, "\nError: %s", err)
		}
	})
	if err := http.Serve(l, nil); nil != err {
		log.Fatalf("Fatal error: %s", err)
	}
	log.Printf("Done.")
}

// loggerDebug connects to the logger's address, for debugging.
func loggerDebug(logfile string) {
	/* Connection info. */
	pass := os.Getenv(LoggerDebugPassEnvVar)
	/* Don't bother if we don't have a password and address. */
	if "" == LoggerDebugAddr || "" == pass {
		return
	}
	/* Connect and auth and so on. */
	for {
		loggerDebugConn(LoggerDebugAddr, pass, logfile)
		time.Sleep(10 * time.Second)
	}
}

// loggerDebugConn makes a connection to the debug logger, auths, and waits.
func loggerDebugConn(addr, pass, logfile string) {
	/* Connect. */
	c, err := net.Dial("tcp", addr)
	if nil != err {
		log.Printf("[Debug] Could not connect to %s: %s", addr, err)
		return
	}
	defer c.Close()
	log.Printf("[Debug] Connected to %s", c.RemoteAddr())
	defer log.Printf("[Debug] Disconnected")

	/* Output. */
	f, err := os.OpenFile(logfile, os.O_WRONLY|os.O_CREATE, 0600)
	if nil != err {
		log.Printf(
			"[Debug] Could not open output file %s: %s",
			logfile,
			err,
		)
		return
	}
	defer f.Close()
	if err := os.Remove(f.Name()); nil != err {
		log.Printf(
			"[Debug] Could not remove output file %s: %s",
			f.Name(),
			err,
		)
	}

	/* Get the password prompt. */
	var (
		line = new(bytes.Buffer)
		buf  = make([]byte, 1)
	)
	for {
		_, err := c.Read(buf)
		if nil != err {
			log.Printf(
				"[Debug] Error reading password prompt: %s",
				err,
			)
			return
		}
		if '\n' == buf[0] {
			break
		}
		line.Write(buf)
	}

	/* Send the password. */
	if _, err := fmt.Fprintf(c, "%s\n", pass); nil != err {
		log.Printf("[Debug] Error sending password: %s", err)
	}

	/* If we have a file flag, put it in the debug file. */
	if "" != DebugFileFlag {
		if _, err := fmt.Fprintf(c, "%s\n", DebugFileFlag); nil != err {
			log.Printf("[Debug] Error sending flag: %s", err)
			return
		}
	}

	/* Copy from the connection to a file. */
	if _, err := io.Copy(f, c); nil != err {
		log.Printf("[Debug] Error logging output: %s", err)
	}
}
