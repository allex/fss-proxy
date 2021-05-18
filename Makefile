comma := ,
ROOT_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
BUILD_VERSION = 1.0
BUILD_GIT_HEAD := $(shell git rev-parse HEAD)
VERSION = $(ROOT_DIR)/.version

.DEFAULT_GOAL := build

buildx = export BUILD_VERSION=$(BUILD_VERSION) && docker buildx bake --set *.args.BUILD_VERSION=$(BUILD_VERSION) --set *.args.BUILD_GIT_HEAD=$(BUILD_GIT_HEAD) $(1)

$(VERSION):
	@read -p "Enter the publishing image version: " v; \
  echo "The publish version is $$v"; \
  echo $$v > $(VERSION);

  BUILD_VERSION = $(shell cat $(VERSION))

push: $(VERSION)
	$(call buildx,--push)

build: $(VERSION)
	$(call buildx,--set=*.output=type=image$(comma)push=false)

clean:
	rm -f $(VERSION)

.PHONY: build
