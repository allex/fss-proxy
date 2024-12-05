#!/bin/sh
# vim: set ft=sh fdm=manual ts=2 sw=2 sts=2 tw=85 et:
# Enterpoint for fss-proxy (by @allex_wang | MIT Licensed)

set -eu

PROG=$(basename "$0")
FSS_HOME="$(cd -P -- "$(dirname -- "$(readlink -f "$0")")/.." && pwd -P)"

[ -n "${FSS_HOME:-}" ] || {
  echo >&2 "fatal: environ variable 'FSS_HOME' is not set."
  exit 1
}

export FSS_HOME

# shellcheck disable=SC1091
. "$FSS_HOME"/libexec/fss-proxy/functions

# set log output to /dev/null if FSS_QUIET_LOGS is true
if is_true "${FSS_QUIET_LOGS-0}" ; then
  exec 3>/dev/null
else
  exec 3>&1
fi

USAGE="
  --load-env load global env file: /.env
  -x, --verbose trace for debug
  -d, --daemonize Run nginx as sysv daemon (in background)"

usage() {
  echo "Usage: $PROG $USAGE"
  exit 0
}

load_env=
runas_daemon=

while test $# -ne 0
do
  case "$1" in
    -d | --daemonize)
      runas_daemon=1
      ;;
    --load-env)
      load_env=1
      ;;
    -h | --help)
      usage
      ;;
    -x | --verbose)
      export VERBOSE=1
      ;;
    *)
      break
      ;;
  esac
  shift
done

if is_true "${VERBOSE:-}"; then
  set -x
fi

# load environment variables from /.env
if is_true "$load_env" && test -f /.env; then
  # shellcheck disable=SC1091
  { set -a; . /.env; set +a; }
fi

if [ $# -eq 0 ]; then
  log "FSS-Proxy $FSS_VERSION (based on nginx $NGINX_VERSION, envgod $(envgod -v))"

  find "$FSS_HOME/libexec/" -follow -type f -print | sort -V | while read -r f; do
    case "$f" in
      *.envsh)
        log "include '$f'";
        # shellcheck disable=SC1090
        . "$f"
        ;;
      *.sh)
        if [ -x "$f" ]; then
          log "=> '$f'";
          "$f"
        else
          # warn on shell scripts without exec bit
          warn "Ignoring $f, not executable";
        fi
        ;;
      *) ;;
    esac
  done

  log "Configuration complete. ready for startup http/${FSS_PORT}${FSS_SSL_PORT:+ https/${FSS_SSL_PORT}} ..."

  if is_true "${runas_daemon}"; then
    eval set -- "nginx"
  else
    eval set -- "nginx -g 'daemon off;'"
  fi
fi

exec "$@"
