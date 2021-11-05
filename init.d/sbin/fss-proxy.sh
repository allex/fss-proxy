#!/bin/sh
# vim: set ft=sh fdm=manual ts=2 sw=2 sts=2 tw=85 et:

# ================================================
# Description: fss-proxy bootstrap entrypoint
# Author: @allex_wang (allex.wxn@gmail.com)
# Last Modified: Thu Nov 04, 2021 23:48
# ================================================

set -e
[ "${VERBOSE:-}" = "true" ] && set -x

NGX_FILE=/etc/nginx/conf.d/default.conf

# shellcheck disable=SC1091
if [ -f /.env ]; then
  set -a
  . /.env
  set +a
fi

# Execute patch script optionally, `PATCH_FILE` has been deprecated, use `PATCH_ENTRY` instead
PATCH_ENTRY="${PATCH_ENTRY:-${PATCH_FILE:-}}"
if [ -f "$PATCH_ENTRY" ]; then
  chmod +x "$PATCH_ENTRY"
  $PATCH_ENTRY
fi

# Evaluate ngx config template with envs
envgod < "$NGX_FILE" > "$NGX_FILE".tmp && mv "$NGX_FILE".tmp "$NGX_FILE"

if [ $# -gt 0 ]; then
  nginx "$@"
else
  echo >&2 "Start fss-proxy at port ${FSS_PORT} ..."
  nginx -g 'daemon off;'
fi
