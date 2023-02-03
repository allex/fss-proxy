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

BUILD_VERSION ?= $(shell cat .version 2>/dev/null)

get_version = \
	set -eu; \
	ver=$(BUILD_VERSION); \
	if [ ! "$$ver" ]; then \
		if [ -f .version ]; then \
			ver=`cat .version`; \
		fi \
	fi; \
	[ -n "$$ver" ] || exit 1; \
	prerelease=$(prerelease); \
	if [ -n "$$prerelease" ]; then \
		nextver=$$(echo "$$ver" | awk -F. -v OFS=. '$$NF~"[0-9]+"{$$NF++}{print}'); \
		ver="$${nextver%%-$$prerelease}-$$prerelease"; \
	fi; \
	echo $$ver

.DEFAULT_GOAL := build

docker-build = \
	docker buildx build $(1) $(2)

# enable push mode: > make push=1 build
docker-build-args = \
	--build-arg BUILD_VERSION=$(release_tag) \
	--build-arg BUILD_GIT_HEAD=$(shell git rev-parse HEAD) \
	--label "tdio.fss-proxy.dist=$(IMAGE_NAME):$(release_tag)" \
	--platform=$(platform) \
	$(if $(push),--push,--load)

# get image name list, eg: tdio/foo:1.0 tdio/foo:latest tdio/foo:8.x
get-image-names = \
	$(foreach k,$(sort $(subst $(comma), ,$(shell echo "$(release_tag),$(tags)"))),$(IMAGE_NAME):$(k))

.version:
	@echo $(BUILD_VERSION) > .version

version:
	@read -p "Enter a new version: ${BUILD_VERSION:+ (current: ${BUILD_VERSION})}" v; \
	if [ "$$v" ]; then \
		echo "The publish version is: $$v"; \
		echo $$v > $(ROOT_DIR)/.version; \
	fi

release_tag = $(shell $(get_version))

build: .version
ifeq ($(strip $(BUILD_VERSION)),)
	$(error "$${BUILD_VERSION} not defined, run 'make version' first")
endif
	# Start build docker image $(release_tag)
	$(call docker-build, $(foreach t,$(get-image-names),-t $(t)), $(docker-build-args)) .

clean:
	rm -f .version
	docker rmi -f $(get-image-name) &>/dev/null

.PHONY: build
