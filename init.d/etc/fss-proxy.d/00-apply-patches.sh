#!/bin/sh
#by @allex_wang

set -e

ME=$(basename "$0")

INSTALL_LOCK_FILE="$HOME/.fss-proxy-install.lock"

if [ -f "$INSTALL_LOCK_FILE" ]; then
  echo "${ME}: already installed, skip."
  exit 0
fi

# Auto detect patch entry by env `$PATCH_ENTRYPOINT`
apply_patches () {
  patch_file="${PATCH_ENTRYPOINT:-${PATCH_FILE:-}}"

  # Excute patch script if it exists
  if [ -x "$patch_file" ]; then
    if [ "$(id -u)" != "0" ]; then
      sudo chmod o+w /etc/nginx/
    fi

    "$patch_file"
  fi
}

apply_patches || exit 1

touch "$INSTALL_LOCK_FILE"
