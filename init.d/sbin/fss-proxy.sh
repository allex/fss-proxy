#!/bin/sh
# vim: set ft=sh fdm=manual ts=2 sw=2 sts=2 tw=85 et:

# ================================================
# Description: fss-proxy bootstrap entrypoint
# Author: @allex_wang (allex.wxn@gmail.com)
# Last Modified: Thu Sep 14, 2023 14:25
# ================================================
set -eu

PROG=$(basename "$0")
FSS_CONF_DIR="/etc/fss-proxy.d"

# shellcheck source=/dev/null
. "${FSS_CONF_DIR}/.helpers/functions"

[ "${VERBOSE:-}" = "true" ] && set -x

if [ "$(id -u)" != "0" ]; then
  sudo chmod o+w /tmp
fi

export NGINX_VERSION="${NGINX_VERSION:-$(nginx -v 2>&1 |awk -F/ '{print $2}')}"

if [ $# -eq 0 ]; then
  echo "FSS-Proxy $FSS_VERSION (based on nginx $NGINX_VERSION, envgod $(envgod -v))"

  # shellcheck disable=SC1091
  [ -f /.env ] && { set -a; . /.env; set +a; }

  export PATCH_ENTRYPOINT="${PATCH_ENTRYPOINT:-${PATCH_FILE:-}}"

  # Execute patch script optionally
  if [ -f "$PATCH_ENTRYPOINT" ]; then
    if [ "$(id -u)" != "0" ]; then
      sudo chmod o+w "$(dirname "$PATCH_ENTRYPOINT")" /etc/nginx/
    fi
    sh "$PATCH_ENTRYPOINT"
  fi

  # been used for shell scripts in /etc/fss-prox.d/
  exec 3>&1

  # export for cross script contexts
  export FSS_CONF_DIR

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
      *) ;;
    esac
  done

  echo "Trying to launch server at http/${FSS_PORT}${FSS_SSL_PORT:+ https/${FSS_SSL_PORT}} ..."
  eval set -- "nginx -g 'daemon off;'"
fi

exec "$@"
