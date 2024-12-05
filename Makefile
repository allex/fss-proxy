# Makefile for build fss-proxy
# by allex_wang

ROOT_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
GIT_COMMIT := $(shell git rev-parse HEAD)
LATEST_TAG := $(shell git log --decorate --pretty="format:%d" | awk 'match($$0, "[(]?tag:\\s*v?([^,]+?)[,)]", arr) { if(arr[1] ~ "^.+?[0-9]+\\.[0-9]+\\.[0-9]+(-.+)?$$") print arr[1]; exit; }')

# flag to disable automate version if set true
STATIC_VERSION := false

comma := ,
platform ?= linux/amd64,linux/arm64

# prerelease tag, such as dev,rc,next etc,.
prerelease ?=

# Specify the release type manully, <major|minor|patch>, default release as last tag
# increase patch version when prerelease mode
release_as ?= patch

# check static version mode, set with args: VERSION=xxx
ifeq ($(origin VERSION), command line)
	# Variable is defined via command parameter
	STATIC_VERSION := true
	LATEST_TAG := $(VERSION)
endif

IS_LATEST := false
ifeq ($(shell git describe --tags --exact-match --match $(LATEST_TAG) >/dev/null 2>&1; echo $$?), 0)
	STATIC_VERSION := true
	IS_LATEST := true
endif

ifneq ($(STATIC_VERSION),true)
	ifneq ($(origin prerelease), command line)
		prerelease := dev
	endif
endif

get_version = \
	set -eu; \
	ver=$(LATEST_TAG); \
	[ -n "$$ver" ] || exit 1; \
	if [ "$(IS_LATEST)" != "true" -a $(STATIC_VERSION) != "true" ]; then \
		release_as=$$(echo $(release_as) | sed "s/major/M/;s/minor/m/;s/patch/p/"); \
		ver=$$(echo "$$ver" | awk -v release_as=$$release_as 'BEGIN{FS=OFS="."} release_as~"^v?[0-9]+(\\.[0-9]+)*$$"{print gensub("^v","","g",release_as);exit} $$0~"(\\.[0-9]+)+$$"{ i=index("Mmp", release_as); if (i!=0) { $$i++; while (i<3) {$$(++i)=0} } print }'); \
		ver=$${ver:-$(LATEST_TAG)}; \
	fi; \
	prerelease=$(prerelease); \
	if [ -n "$$prerelease" ]; then \
		ver="$${ver%%-$$prerelease}-$$prerelease"; \
	fi; \
	echo $$ver

# export for sub shell
export RELEASE_TAG := $(shell $(get_version))

# custom tags for multi image distribute, sep by comma (,), eg: make build tags=1.0.1,latest,next,1.x
tags ?=

prefix ?= harbor.tidu.io/tdio

ifndef prefix
	$(error docker registry prefix not valid)
endif

image_name ?= $(prefix)/fss-proxy

docker-build = \
	docker buildx build $(1) $(2)

NGINX_VERSION ?= 1.25.2

# enable push mode: > make push=1 build
docker-build-args = \
	--build-arg NGINX_VERSION=$(NGINX_VERSION) \
	--build-arg BUILD_VERSION=$(RELEASE_TAG) \
	--build-arg BUILD_GIT_COMMIT=$(GIT_COMMIT) \
	--label "tdio.fss-proxy.dist=$(image_name):$(RELEASE_TAG)" \
	--platform=$(platform) \
	$(if $(push),--push,--load)

# get image name list, eg: tdio/foo:1.0 tdio/foo:latest tdio/foo:8.x
get-image-names = \
	$(foreach k,$(sort $(subst $(comma), ,$(shell echo "$(RELEASE_TAG),$(tags)"))),$(image_name):$(k))

.DEFAULT_GOAL := help

.PHONY: build help

# Parse Makefile and display the help
## > help - Show help
help:
	# Commands:
	@grep -E '^## > [a-zA-Z_-]+.*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = "## > "}; {printf ">\033[36m%-1s\033[0m %s\n", $$1, $$2}'

## > version [release_as=patch|minor|major] [prerelease=<dev|rc|xxx>] - show build version
version:
	@echo "Name: $(image_name)"
	@echo "Version: $${RELEASE_TAG}"
	@echo "Commit: $(GIT_COMMIT)"

## > build [release_as=patch|minor|major] [prerelease=<dev|rc|xxx>] [push=1] [VERSION=x.y.z] [NGINX_VERSION=1.25.2] - build docker image
build:
	# Start build docker image $(RELEASE_TAG)
	$(call docker-build, $(foreach t,$(get-image-names),-t $(t)), $(docker-build-args)) .
	@echo $(RELEASE_TAG) > .version

## > dry-release - dry run release
dry-release:
	git release --from-version $(LATEST_TAG) -r patch -d

clean:
	# Cleanup build caches
	docker rmi -f $(get-image-name) &>/dev/null

## > test - testing with docker compose service
test:
	docker compose run --build test-build
