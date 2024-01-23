# Makefile for build fss-proxy
# by allex_wang

ROOT_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

comma := ,
platform ?= linux/amd64,linux/arm64
prefix ?= harbor.tidu.io/tdio

# custom tags for multi image distribute, sep by comma (,), eg: make build tags=1.0.1,latest,next,1.x
tags ?=

# pre-release name, eg. dev, bate, rc
prerelease ?=

ifndef prefix
	$(error prefix not valid)
endif

IMAGE_NAME ?= $(prefix)/fss-proxy

GIT_COMMIT := $(shell git rev-parse HEAD)
LAST_TAG ?= $(shell git log --decorate --no-color --pretty="format:%d" |awk 'match($$0, "[(]?tag:\\s*v?([^,]+?)[,)]", arr) { if(arr[1] ~ "^.+?[0-9]+\\.[0-9]+\\.[0-9]+(-.+)?$$") print arr[1]; exit; }')

# check static version mode
ifeq ($(origin VERSION), command line)
	# Variable is defined via command parameter
	STATIC_VERSION := true
else
	STATIC_VERSION := false
	# detect the reference version to auto generate the build version.
	ifneq ("$(wildcard .version)","")
		VERSION := $(shell cat .version 2>/dev/null)
	else
		VERSION := $(LAST_TAG)
	endif
endif

# Specify the release type manully, <major|minor|patch>, default release as last tag
# increase patch version when prerelease mode
release_as ?= patch

get_version = \
	set -eu; \
	ver=$(VERSION); \
	[ -n "$$ver" ] || exit 1; \
	if [ "$(STATIC_VERSION)" != "true" ]; then \
		release_as=$$(echo $(release_as) | sed "s/major/M/;s/minor/m/;s/patch/p/"); \
		ver=$$(echo "$$ver" | awk -v release_as=$$release_as 'BEGIN{FS=OFS="."} release_as~"^v?[0-9]+(\\.[0-9]+)*$$"{print gensub("^v","","g",release_as);exit} $$0~"(\\.[0-9]+)+$$"{ i=index("Mmp", release_as); if (i!=0) { $$i++; while (i<3) {$$(++i)=0} } print }'); \
		ver=$${ver:-$(VERSION)}; \
	fi; \
	prerelease=$(prerelease); \
	if [ -n "$$prerelease" ]; then \
		ver="$${ver%%-$$prerelease}-$$prerelease"; \
	fi; \
	echo $$ver

release_tag := $(shell $(get_version))

docker-build = \
	docker buildx build $(1) $(2)

NGINX_VERSION ?= 1.25.2

# enable push mode: > make push=1 build
docker-build-args = \
	--build-arg NGINX_VERSION=$(NGINX_VERSION) \
	--build-arg BUILD_VERSION=$(release_tag) \
	--build-arg BUILD_GIT_HEAD=$(shell git rev-parse HEAD) \
	--label "tdio.fss-proxy.dist=$(IMAGE_NAME):$(release_tag)" \
	--platform=$(platform) \
	$(if $(push),--push,--load)

# get image name list, eg: tdio/foo:1.0 tdio/foo:latest tdio/foo:8.x
get-image-names = \
	$(foreach k,$(sort $(subst $(comma), ,$(shell echo "$(release_tag),$(tags)"))),$(IMAGE_NAME):$(k))

.DEFAULT_GOAL := help

.PHONY: build help

# Parse Makefile and display the help
## > help - Show help
help:
	# Commands:
	@grep -E '^## > [a-zA-Z_-]+.*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = "## > "}; {printf ">\033[36m%-1s\033[0m %s\n", $$1, $$2}'

.version:
	@echo $(VERSION) > .version

version:
	@read -p "Enter a new version: ${VERSION:+ (current: ${VERSION})}" v; \
	if [ "$$v" ]; then \
		echo "The publish version is: $$v"; \
		echo $$v > $(ROOT_DIR)/.version; \
	fi

## > build [release_as=patch|minor|major] [prerelease=<dev|rc|xxx>] [push=1] [VERSION=x.y.z] [NGINX_VERSION=1.25.2] - build docker image
build: .version
ifeq ($(strip $(VERSION)),)
	$(error "VERSION not defined, run 'make version' first")
endif
	# Start build docker image $(release_tag)
	$(call docker-build, $(foreach t,$(get-image-names),-t $(t)), $(docker-build-args)) .

## > dry-release - dry run release
dry-release:
	git release -d

clean:
	# Cleanup build caches
	rm -f .version
	docker rmi -f $(get-image-name) &>/dev/null
