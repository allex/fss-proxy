# by allex_wang

function image_name {
  params = [prefix, name]
  result = notequal("", prefix) ? "${prefix}/${name}" : "${name}"
}

variable "IMAGE_NAME" {
  default = "fss-proxy"
}

variable "PREFIX" {
  default = "docker.io/tdio"
}

variable "BUILD_VERSION" {
  default = ""
}

group "default" {
  targets = ["mainline"]
}

target "mainline" {
  context = "."
  dockerfile = "Dockerfile"
  args = {
    BUILD_VERSION = ""
    BUILD_GIT_HEAD = ""
  }
  tags = [
    "${image_name(PREFIX, IMAGE_NAME)}:latest",
    "${image_name(PREFIX, IMAGE_NAME)}:${BUILD_VERSION}"
  ]
  platforms = ["linux/amd64","linux/arm64"]
}
