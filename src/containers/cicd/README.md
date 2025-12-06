cicd
====
A small CI/CD server which accepts jobs as HTTP POST requests.  Jobs should be
specified in Bash.  Output will be returned.

Usage
-----
```
Usage: cicd [options]

CI/CD program which takes shell scripts via HTTPS POST requests

Options:
  -listen address
    	Listen address (default "0.0.0.0:4433")
  -password password
    	HTTP basic auth password
  -shell path
    	Shell path (default "/bin/bash")
```
