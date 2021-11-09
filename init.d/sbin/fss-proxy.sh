#!/bin/sh
# vim: set ft=sh fdm=manual ts=2 sw=2 sts=2 tw=85 et:

# ================================================
# Description: fss-proxy bootstrap entrypoint
# Author: @allex_wang (allex.wxn@gmail.com)
# Last Modified: Tue Nov 09, 2021 13:36
# ================================================

set -e
[ "${VERBOSE:-}" = "true" ] && set -x

echo "FSS-Proxy $FSS_VERSION (based on nginx $NGINX_VERSION, envgod 1.0.0)"

NGX_FILE=/etc/nginx/conf.d/default.conf

# shellcheck disable=SC1091
[ -f /.env ] && {
  set -a
  . /.env
  set +a
}

# `PATCH_FILE` was deprecated since 1.1.4, use `PATCH_ENTRYPOINT` instead
if [ -n "$PATCH_FILE" ]; then
  echo >&2 "'PATCH_FILE' was deprecated since v1.1.6, use 'PATCH_ENTRYPOINT' instead"
fi
PATCH_ENTRYPOINT="${PATCH_ENTRYPOINT:-${PATCH_FILE:-}}"

# Execute patch script optionally
if [ -f "$PATCH_ENTRYPOINT" ]; then
  chmod +x "$PATCH_ENTRYPOINT"
  $PATCH_ENTRYPOINT
fi

# Evaluate ngx config template with envs
envgod <"$NGX_FILE" | sed "/^ *$/d" >"$NGX_FILE".tmp && mv "$NGX_FILE".tmp "$NGX_FILE"

if [ $# -gt 0 ]; then
  exec "$@"
else
  echo >&2 "Start server at port ${FSS_PORT} ..."
  nginx -g 'daemon off;'
fi
