# Makefile for build fss-proxy
# by allex_wang

ROOT_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

comma := ,
platform ?= linux/amd64,linux/arm64
prefix ?= harbor.tidu.io/tdio

# custom tags for multi image distribute, sep by comma (,), eg: make build tags=1.0.1,latest,next,1.x
tags ?=

ifndef prefix
	$(error prefix not valid)
endif

IMAGE_NAME = $(prefix)/fss-proxy

ifneq ("$(wildcard .version)","")
	BUILD_VERSION := $(shell cat .version)
endif

.DEFAULT_GOAL := build

docker-build = \
	docker buildx build $(1) $(2)

# enable push mode: > make push=1 build
docker-build-args = \
	--build-arg BUILD_VERSION=$(BUILD_VERSION) \
	--build-arg BUILD_GIT_HEAD=$(shell git rev-parse HEAD) \
	--label "tdio.fss-proxy.dist=$(IMAGE_NAME):$(BUILD_VERSION)" \
	--platform=$(platform) \
	$(if $(push),--push,--load)

# get image name list, eg: tdio/foo:1.0 tdio/foo:latest tdio/foo:8.x
get-image-names = \
	$(foreach k,$(sort $(subst $(comma), ,$(shell echo "$(BUILD_VERSION),$(tags)"))),$(IMAGE_NAME):$(k))

.version:
	@echo $(BUILD_VERSION) > .version

version:
	@read -p "Enter a new version: ${BUILD_VERSION:+ (current: ${BUILD_VERSION})}" v; \
	if [ "$$v" ]; then \
		echo "The publish version is: $$v"; \
		echo $$v > $(ROOT_DIR)/.version; \
	fi

build: .version
ifndef BUILD_VERSION
	$(error "'BUILD_VERSION' not defined, run 'make version' first")
endif
	$(call docker-build, $(foreach t,$(get-image-names),-t $(t)), $(docker-build-args)) .

clean:
	rm -f .version
	docker rmi -f $(get-image-name)

.PHONY: build
