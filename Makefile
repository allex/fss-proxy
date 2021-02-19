comma := ,
BUILD_TAG := 1.1.0
BUILD_GIT_HEAD := $(shell git rev-parse HEAD)
DOCKER_BUILD_ARGS := --set *.args.BUILD_TAG=$(BUILD_TAG) --set *.args.BUILD_GIT_HEAD=$(BUILD_GIT_HEAD)

.DEFAULT_GOAL := build

buildx = export BUILD_TAG=$(BUILD_TAG) && docker buildx bake $(DOCKER_BUILD_ARGS) $(1)

push:
	$(call buildx,--push)

build:
	$(call buildx,--set=*.output=type=image$(comma)push=false)

.PHONY: build
