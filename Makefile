comma := ,
ROOT_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
BUILD_TAG = 1.0
BUILD_GIT_HEAD := $(shell git rev-parse HEAD)
VERSION = $(ROOT_DIR)/.version

.DEFAULT_GOAL := build

buildx = export BUILD_TAG=$(BUILD_TAG) && docker buildx bake --set *.args.BUILD_TAG=$(BUILD_TAG) --set *.args.BUILD_GIT_HEAD=$(BUILD_GIT_HEAD) $(1)

$(VERSION):
	@read -p "Enter the publishing image version: " v; \
  echo "The publish version is $$v"; \
  echo $$v > $(VERSION);

  BUILD_TAG = $(shell cat $(VERSION))

push: $(VERSION)
	$(call buildx,--push)

build: $(VERSION)
	$(call buildx,--set=*.output=type=image$(comma)push=false)

clean:
	rm -f $(VERSION)

.PHONY: build
