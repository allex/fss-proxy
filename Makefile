# Makefile for build fss-proxy
# by allex_wang
ROOT_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

platform ?= linux/amd64,linux/arm64
prefix ?= tdio

ifndef prefix
	$(error prefix not valid)
endif

IMAGE_NAME = $(prefix)/fss-proxy

ifneq ("$(wildcard .version)","")
	BUILD_VERSION := $(shell cat .version)
endif

.DEFAULT_GOAL := build

docker-build = \
	export PREFIX=$(prefix); \
	export BUILD_VERSION=$(BUILD_VERSION); \
	docker buildx bake $(1)

# enable push mode: > make push=1 build
docker-build-args = \
	--set *.args.BUILD_VERSION=$(BUILD_VERSION) \
	--set *.args.BUILD_GIT_HEAD=$(shell git rev-parse HEAD) \
	--set *.platform=$(platform) \
	$(if $(push),--push,--load)

get-image-name = \
	$(IMAGE_NAME):$(BUILD_VERSION)

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
	$(call docker-build, $(docker-build-args))

clean:
	rm -f .version
	docker rmi -f $(get-image-name)

.PHONY: build
