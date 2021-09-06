#!/bin/sh
# vim: set ft=sh fdm=manual ts=2 sw=2 sts=2 tw=85 et:

# ================================================
# Description: on-build for steamer-ui-base builder
# Last Modified: Mon Sep 06, 2021 14:02
# Author: Allex Wang (allex.wxn@gmail.com)
# ================================================
set -eu

sf="$0"
trap "[ -f '$sf' ] && rm -f -- '$sf'" 0 1 2 3 9 13 15

(
  [ "${VERBOSE/true/1}" = "1" ] && { set -x; printenv | sort; }
  [ -z "${BUILD_VERSION}" ] && { echo >&2 '${BUILD_VERSION} required'; exit 1; }

  cd /var/www
  if [ -f ./index.html ]; then
    echo "<!-- ${BUILD_VERSION##v} | ${BUILD_GIT_HEAD} -->" >> ./index.html
  fi
)

echo "[on-build] done."
