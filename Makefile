SHELL := /bin/bash
DESTDIR := /
EXTLDFLAGS := -static -s
LDFLAGS := -buildid='' -extldflags '${EXTLDFLAGS}'
#-extldflags=${EXTLDFLAGS}
GO_BUILD := garble -tiny -seed=random -literals build -v

.PHONY: all build clean help install test depends

all: test clean ## Default target, runs the build

test: install
	garble build -v -x

depends:
	export GOPROXY=on;\
	export GO111MODULE=on;\
	# Downloading go modules
	go mod tidy;\
	go mod download;\

build: depends
	export GO111MODULE=on; \
	export GOPROXY=on;\
	# Building
	CGO_ENABLED=0 GOARCH=386 GOOS=linux  go build -ldflags=" -s -extldflags='-static'" -o garble-linux-i386;\
	CGO_ENABLED=0 GOARCH=arm GOOS=linux  go build -ldflags=" -s -extldflags='-static'" -o garble-linux-arm;\
	CGO_ENABLED=0 GOARCH=arm64 GOOS=linux  go build -ldflags=" -s -extldflags='-static'" -o garble-linux-arm64;\
	CGO_ENABLED=0 GOARCH=amd64 GOOS=linux  go build -ldflags=" -s -extldflags='-static'" -o garble-linux-amd64;\
	CGO_ENABLED=1 GOARCH=amd64 GOOS=android  go build -ldflags=" -s -extldflags='-static'" -o garble-android-amd64;\
	CGO_ENABLED=1 GOARCH=arm GOOS=android  go build -ldflags=" -s -extldflags='-static'" -o garble-android-arm;\
	CGO_ENABLED=0 GOARCH=arm64 GOOS=android  go build -ldflags=" -s -extldflags='-static'" -o garble-android-arm64;\
	CGO_ENABLED=0 GOARCH=amd64 GOOS=windows  go build -ldflags=" -s -extldflags='-static'" -o garble-windows-amd64.exe;\
	CGO_ENABLED=0 GOARCH=386 GOOS=windows  go build -ldflags=" -s -extldflags='-static'" -o garble-windows-i386.exe;\
	CGO_ENABLED=0 GOARCH=arm64 GOOS=windows  go build -ldflags=" -s -extldflags='-static'" -o garble-windows-arm64.exe; \
	CGO_ENABLED=0 GOARCH=arm GOOS=windows  go build -ldflags=" -s -extldflags='-static'" -o garble-windows-arm.exe; \
	CGO_ENABLED=0 GOARCH=mips GOOS=linux  go build -ldflags=" -s -extldflags='-static'" -o garble-linux-mips;

	
install: ## Install the appropriate binary based on the host architecture and OS
	sudo rm $(shell which garble);\
	sudo go mod tidy
	sudo go build -ldflags=" -w -buildid='' -s -extldflags='-static'" -o /usr/bin/garble;\
	sudo upx -f /usr/bin/garble;\
	
clean:
	sudo rm -f garble*|| true;\
	sudo rm -rfv ${HOME}/.cache;\
	sudo rm -rfv ${HOME}/go;\
	sudo rm -rfv /root/.cache /root/go;\


help:
	@printf "Makefile for developing and building dns-tor-proxy\n"
	@printf "Subcommands:\n"
	@awk 'BEGIN {FS = ":.*?## "} /^[0-9a-zA-Z_-]+:.*?## / {printf "%s : %s\n", $$1, $$2}' $(MAKEFILE_LIST) \
		| sort \
		| column -s ':' -t
