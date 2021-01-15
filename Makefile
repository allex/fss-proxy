BUILD_TAG := $(shell git-rev)
BUILD_GIT_HEAD := $(shell git rev-parse HEAD)
DOCKER_BUILD_ARGS := --set *.args.BUILD_TAG=$(BUILD_TAG) --set *.args.BUILD_GIT_HEAD=$(BUILD_GIT_HEAD)

.DEFAULT_GOAL := build

push:
	export BUILD_TAG=$(BUILD_TAG) \
	  && docker buildx bake $(DOCKER_BUILD_ARGS) --push

build:
	export BUILD_TAG=$(BUILD_TAG) \
	  && docker buildx bake $(DOCKER_BUILD_ARGS) --load

.PHONY: build
