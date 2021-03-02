# by allex_wang

function image_name {
  params = [prefix, name]
  result = notequal("", prefix) ? "${prefix}/${name}" : "${name}"
}

variable "NAME" {
  default = "steamer-ui-origin"
}

variable "PREFIX" {
  default = "docker.io/tdio"
}

variable "BUILD_TAG" {
  default = "6.0.0"
}

group "default" {
  targets = ["6.x"]
}

target "6.x" {
  context = "."
  dockerfile = "Dockerfile"
  args = {
    BUILD_TAG = ""
    BUILD_GIT_HEAD = ""
  }
  tags = [
    "${image_name(PREFIX, NAME)}:${BUILD_TAG}"
  ]
  platforms = ["linux/amd64","linux/arm64"]
}
