#!/bin/sh
# vim: set ft=sh fdm=manual ts=2 sw=2 sts=2 tw=85 et:
# Enterpoint for fss-proxy (by @allex_wang | MIT Licensed)

set -eu

PROG=$(basename "$0")

[ -n "$FSS_CONF_DIR" ] || {
  echo >&2 "ERR: environ variable 'FSS_CONF_DIR' is not set."
  exit 1
}

# shellcheck source=/dev/null
. "$FSS_CONF_DIR"/.helpers/functions

if [ "${VERBOSE:-}" = "true" ]; then
  set -x
fi

if [ $# -eq 0 ]; then
  echo "FSS-Proxy $FSS_VERSION (based on nginx $NGINX_VERSION, envgod $(envgod -v))"

  # shellcheck disable=SC1091
  if [ -f /.env ]; then
    # load environment variables from /.env
    set -a; . /.env; set +a
  fi

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
      *) ;;
    esac
  done

  echo "Trying to launch server at http/${FSS_PORT}${FSS_SSL_PORT:+ https/${FSS_SSL_PORT}} ..."
  eval set -- "nginx -g 'daemon off;'"
fi

exec "$@"
