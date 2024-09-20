SHELL := /bin/bash g
DESTDIR := /
EXTLDFLAGS := -static -s
LDFLAGS := -buildid='' -extldflags '${EXTLDFLAGS}'
#-extldflags=${EXTLDFLAGS}
GO_BUILD := garble -tiny -seed=random -literals build -v

.PHONY: all build clean help install depends

all: install ## Default target, runs the build

depends: garble
	export GOPROXY=on;\
	export GO111MODULE=on;\
	# Downloading go modules
	go mod tidy -x

build: depends
	export GO111MODULE=on; \
	export GOPROXY=on;\
	# Building
	CGO_ENABLED=1 go build -x -v -o garble;\
	
install: build ## Install the appropriate binary based on the host architecture and OS
	sudo install -m 0655 garble /usr/bin
clean:
	rm -f garble

help:
	@printf "Makefile for developing and building dns-tor-proxy\n"
	@printf "Subcommands:\n"
	@awk 'BEGIN {FS = ":.*?## "} /^[0-9a-zA-Z_-]+:.*?## / {printf "%s : %s\n", $$1, $$2}' $(MAKEFILE_LIST) \
		| sort \
		| column -s ':' -t
