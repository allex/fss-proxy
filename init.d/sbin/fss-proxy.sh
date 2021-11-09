#!/bin/sh
# vim: set ft=sh fdm=manual ts=2 sw=2 sts=2 tw=85 et:

# ================================================
# Description: fss-proxy bootstrap entrypoint
# Author: @allex_wang (allex.wxn@gmail.com)
# Last Modified: Wed Nov 10, 2021 17:17
# ================================================
set -e

[ "${VERBOSE:-}" = "true" ] && set -x

echo "FSS-Proxy $FSS_VERSION (based on nginx $NGINX_VERSION, envgod 1.0.0)"

# shellcheck disable=SC1091
[ -f /.env ] && {
  set -a
  . /.env
  set +a
}

# `PATCH_FILE` is deprecated since 1.1.4, use `PATCH_ENTRYPOINT` instead
if [ -n "$PATCH_FILE" ]; then
  echo >&2 "warning: 'PATCH_FILE' is deprecated since v1.1.6, use 'PATCH_ENTRYPOINT' instead"
fi

PATCH_ENTRYPOINT="${PATCH_ENTRYPOINT:-${PATCH_FILE:-}}"

# Execute patch script optionally
if [ -f "$PATCH_ENTRYPOINT" ]; then
  chmod +x "$PATCH_ENTRYPOINT"
  $PATCH_ENTRYPOINT
fi

if [ $# -eq 0 ]; then
  FSS_CONF_DIR=/etc/fss-proxy.d/

  # been used for shell scripts in /etc/fss-prox.d/
  exec 3>&1

  find "$FSS_CONF_DIR" -follow -type f -print | sort -V | while read -r f; do
    case "$f" in
      *.sh)
        if [ -x "$f" ]; then
          "$f"
        else
          # warn on shell scripts without exec bit
          echo >&2 "Ignoring $f, not executable";
        fi
        ;;
      *) echo >&2 "Ignoring $f";;
    esac
  done

  echo >&2 "Ready to start up at port ${FSS_PORT} ..."
  eval set -- "nginx -g 'daemon off;'"
fi

exec "$@"
