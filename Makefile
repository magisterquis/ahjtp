# Makefile
# Build container config and other such things
# By J. Stuart McMurray
# Created 20251201
# Last Modified 20251206

GOBUILDFLAGS   = -trimpath -ldflags "-w -s"
GOTESTFLAGS   += -timeout 3s
SHMORESUBR     = t/shmore.subr
SHMOREURL      = https://raw.githubusercontent.com/magisterquis/shmore/refs/heads/master/shmore.subr
MAKEFILES     != find src -name Makefile
TOBUILD        = compose.json user-data.sh

.include "src/inc/build.mk"

all: build test ## Build and test ALL the things (default).
.PHONY: all

build: ${TOBUILD} ## Build everything.
.PHONY: build

# Builds actually happen in src but are copied here for convenience.
.for T in ${TOBUILD}
$T: src/$T/$T
	cp $> $@
src/$T/$T! call_make
.endfor

test: ## Run ALL the tests!
	go test ${GOBUILDFLAGS} ${GOTESTFLAGS} ./...
	go vet ${GOBUILDFLAGS} ./...
	staticcheck ./...
	prove -It --directives
.PHONY: test

update: ## Fetch the latest Shmore and up-to-date Go things.
	curl\
		--fail\
		--show-error\
		--silent\
		--output ${SHMORESUBR}.new\
		${SHMOREURL}
	diff -q ${SHMORESUBR} ${SHMORESUBR}.new >/dev/null &&\
		rm ${SHMORESUBR}.new ||\
		mv ${SHMORESUBR}.new ${SHMORESUBR}
	go get -t -u go ./...
	go mod tidy
.PHONY: update

clean: ## Remove built things.
	rm -f cannedcurlcommand lasthash
.for D in ${MAKEFILES:H}
	${.MAKE} -C $D clean
	@echo \# Finished in $D
.endfor	
distclean: clean ## Remove more built things.
	rm -rf ${TOBUILD} cannedcurlcommand lasthash
.PHONY: clean distclean

help: .NOTMAIN ## This help.
	@perl -ne '/^(\S+?):+.*?##\s*(.*)/&&print"$$1\t-\t$$2\n"' \
		${MAKEFILE_LIST} | column -ts "$$(printf "\t")"
.PHONY: help
